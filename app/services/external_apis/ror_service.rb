# frozen_string_literal: true

module ExternalApis
  # This service provides an interface to the Research Organization Registry (ROR)
  # API.
  # For more information: https://github.com/ror-community/ror-api
  # rubocop:disable Metrics/ClassLength
  class RorService < BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.ror&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.ror&.api_base_url || super
      end

      def max_pages
        Rails.configuration.x.ror&.max_pages || super
      end

      def max_results_per_page
        Rails.configuration.x.ror&.max_results_per_page || super
      end

      def max_redirects
        Rails.configuration.x.ror&.max_redirects || super
      end

      def active
        Rails.configuration.x.ror&.active || super
      end

      def heartbeat_path
        Rails.configuration.x.ror&.heartbeat_path
      end

      def search_path
        Rails.configuration.x.ror&.search_path
      end

      # Ping the ROR API to determine if it is online
      #
      # @return true/false
      def ping
        return true unless active && heartbeat_path.present?

        resp = http_get(uri: "#{api_base_url}#{heartbeat_path}")
        resp.present? && resp.code == 200
      end

      # Search the ROR API for the given string.
      #
      # @return an Array of Hashes:
      # {
      #   ror: 'https://ror.org/12345',
      #   url: 'example.edu',
      #   name: 'Sample University',
      #   weight: 0
      # }
      # The ROR limit appears to be 40 results (even with paging :/)
      # rubocop:disable Metrics/CyclomaticComplexity
      def search(term:, filters: [])
        return nil unless active && term.present? && ping

        results = process_pages(
          term: term,
          json: query_ror(term: term, filters: filters),
          filters: filters
        )

        # TODO: Consider extracting the bit below (and corresponding functions)
        #       when we build out the curation UI. We will want them to be able
        #       to select from a list

        # We only want exact matches on the name here!
        array = results.select { |rec| rec[:name]&.downcase == term.downcase }
        return nil if array.empty?

        array.empty? ? nil : deserialize_organization(item: array.first)
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'ROR search', error: e)
        []
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      # Queries the ROR API for the sepcified name and page
      def query_ror(term:, page: 1, filters: [])
        return [] unless term.present?

        # build the URL
        target = "#{api_base_url}#{search_path}"
        query = query_string(term: term, page: page, filters: filters)

        # Call the ROR API and log any errors
        resp = http_get(uri: "#{target}?#{query}", additional_headers: {},
                        debug: false)

        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'ROR search', http_response: resp)
          return []
        end
        JSON.parse(resp.body)
      end

      # Build the query string using the search term, current page and any
      # filters specified
      def query_string(term:, page: 1, filters: [])
        query_string = ["query=#{term}", "page=#{page}"]
        query_string << "filter=#{filters.join(',')}" if filters.any?
        query_string.join('&')
      end

      # Recursive method that can handle multiple ROR result pages if necessary
      # rubocop:disable Metrics/CyclomaticComplexity
      def process_pages(term:, json:, filters: [])
        return [] if json.blank?

        results = parse_results(json: json)
        num_of_results = json.fetch('number_of_results', 1).to_i

        # Determine if there are multiple pages of results
        pages = (num_of_results / max_results_per_page.to_f).to_f.ceil
        return results unless pages > 1

        # Gather the results from the additional page (only up to the max)
        (2..(pages > max_pages ? max_pages : pages)).each do |page|
          json = query_ror(term: term, page: page, filters: filters)
          results += parse_results(json: json)
        end
        results || []

      # If we encounter a JSON parse error on subsequent page requests then just
      # return what we have so far
      rescue JSON::ParserError => e
        log_error(method: 'ROR search', error: e)
        results || []
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # Convert the JSON items into a hash
      def parse_results(json:)
        results = []
        return results unless json.present? && json.fetch('items', []).any?

        json['items'].each do |item|
          next unless item['id'].present? && item['name'].present?

          results << {
            ror: item['id'],
            name: item['name'],
            url: item.fetch('links', []).first,
            domain: org_website(item: item),
            country: org_country(item: item),
            abbreviation: item.fetch('acronyms', []).first,
            types: item.fetch('types', []),
            aliases: item.fetch('aliases', []),
            acronyms: item.fetch('acronyms', []),
            labels: item.fetch('labels', [{}]).map { |lbl| lbl[:label] }.compact
          }
        end
        results
      end

      # Extracts the country
      def org_country(item:)
        return '' unless item.present? && item['country'].present?

        item.fetch('country', {}).fetch('country_name', '')
      end

      # Extracts the website domain from the item
      def org_website(item:)
        return nil unless item.present? && item.fetch('links', [])&.any?
        return nil if item['links'].first.blank?

        # A website was found, so extract just the domain without the www
        domain_regex = %r{^(?:http://|www\.|https://)([^/]+)}
        website = item['links'].first.scan(domain_regex).last.first
        website.gsub('www.', '')
      end

      # Extract all of the alternate names from the ROR results
      def gather_names(item:)
        names = []
        return names unless item.present? && item.is_a?(Hash)

        names << item[:domain] if item[:domain].present?
        names << item[:aliases] if item[:aliases].present?
        names << item[:acronyms] if item[:acronyms].present?
        item.fetch(:labels, []).map { |hash| names << hash[:label] }
        names.flatten.compact.uniq
      end

      # Convert the hash content to an Identifier
      def deserialize_identifier(category:, value:)
        return nil unless category.present? && value.present?

        Identifier.find_or_initialize_by(provenance: provenance(name: 'ror'),
                                         value: value,
                                         identifiable_type: 'Affiliation',
                                         category: category.to_sym)
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def deserialize_organization(item:)
        return nil unless item.present? && item[:name].present?

        ror = deserialize_identifier(category: 'ror', value: item[:ror]) if item[:ror].present?
        url = deserialize_identifier(category: 'url', value: item[:url]) if item[:url].present?
        # If any of the identifiers already exists juts return the Organization
        return ror.identifiable if ror.present? && !ror.new_record?
        return url.identifiable if url.present? && !url.new_record?

        org = Affiliation.find_or_initialize_by(provenance: provenance(name: 'ror'),
                                                name: item[:name])
        org.alternate_names = gather_names(item: item)
        org.types = item[:types]
        org.attrs = {
          domain: item.fetch(:domain, ''),
          country: item.fetch(:country, ''),
          abbreviation: item.fetch(:abbreviation, '')
        }
        org.identifiers << ror if ror.present?
        org.identifiers << url if url.present?
        org
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
  # rubocop:enable Metrics/ClassLength
end
