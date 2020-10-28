# frozen_string_literal: true

require 'base64'

module ExternalApis
  # This service provides an interface to Datacite API.
  class CitationService < BaseService
    class << self
      def api_base_url
        Rails.configuration.x.datacite_citation&.api_base_url || Rails.configuration.x.crossref_citation&.api_base_url || super
      end

      def active
        Rails.configuration.x.datacite_citation&.active || Rails.configuration.x.crossref_citation&.active || super
      end

      # Create a new DOI
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def fetch(id:)
        return nil unless active && id.present? && id.is_a?(Identifier)

        resp = http_get(uri: id.value) # , debug: true)

        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'CitationService fetch', http_response: resp)
          persist_citation(id: id, citation: failure_message(doi: id.value), json: {})
          return nil
        end

        json = JSON.parse(resp.body)
        citation = process_json(doi: id.value, json: json)
        # If process_json failed for some reason
        persist_citation(id: id, citation: failure_message(doi: id.value), json: json) if citation == id.value
        persist_citation(id: id, json: json, citation: citation)
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'CitationService fetch JSON parse error', error: e)
        persist_citation(id: id, citation: failure_message(doi: id.value), json: { 'source': 'datacite' })
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      def failure_message(doi:)
        return '' unless doi.present?

        "Unable to find a citation for <a href=\"#{doi}\" target=\"_blank\">#{doi}</a>"
      end

      # Convert the EZID response into identifiers
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def process_json(doi:, json:)
        return doi unless json.present? && json['DOI'].present? &&
                          json.fetch('author', []).any? && json['title'].present? &&
                          json['type'].present? && json['publisher'].present?

        year = detect_publication_year(json: json)
        return doi unless year.present?

        authors = json['author'].map { |author| "#{author['family']}, #{author['given'][0]}." }.join(', ')
        link = "<a href=\"#{doi}\" target=\"_blank\">#{doi}</a>"

        "#{authors} (#{year}). \"#{json['title']}\" [#{json['type'].capitalize}]. In #{json['publisher']}. #{link}"
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Dates are painful and come in this format:
      #   "published-print": { "date-parts": [[2013, 4, 23]] }
      def detect_publication_year(json:)
        year = find_year(hash: json['published-print'])
        year = find_year(hash: json['deposited']) unless year.present?
        year = find_year(hash: json['indexed']) unless year.present?
        year = find_year(hash: json['content-created']) unless year.present?
        year = find_year(hash: json['issued']) unless year.present?
        year = find_year(hash: json['created']) unless year.present?
        year
      end

      def find_year(hash:)
        return nil unless hash.present? && hash['date-parts'].present?

        parts = hash.fetch('date-parts', [[]])
        return nil unless parts[0].present?

        parts[0][0]
      end

      # Drop the existing citation and add the new one
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def persist_citation(id:, citation:, json:)
        return nil unless id.present? && citation.present? && json.present?

        provenance = Provenance.where(name: json['source'].present? ? json['source'].downcase : 'datacite').first

        id.citation.destroy if id.citation.present?
        json_type = json['type']&.gsub('-', '_')&.downcase
        object_type = Citation.object_types.include?(json_type) ? json_type : 'dataset'

        Citation.create(identifier_id: id.id, object_type: object_type,
                        retrieved_on: Time.now, citation_text: citation,
                        original_json: json, provenance: provenance)
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
