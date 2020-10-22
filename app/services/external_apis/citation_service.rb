# frozen_string_literal: true

require 'base64'

module ExternalApis
  # This service provides an interface to Datacite API.
  class CitationService < BaseService
    class << self
      def api_base_url
        Rails.configuration.x.citation&.api_base_url || super
      end

      def active
        Rails.configuration.x.citation&.active || super
      end

      # Create a new DOI
      def fetch(doi:)
        return doi unless doi.present?

        doi = "#{api_base_url}#{doi.gsub(/^doi:/, '')}" unless doi.start_with?('http')
        err_msg = "Unable to generate a citation for #{doi}"

        resp = http_get(uri: doi.to_s) # , debug: true)

        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'CitationService fetch', http_response: resp)
          return err_msg
        end

        citation = process_json(doi: doi, json: JSON.parse(resp.body))
        return citation unless citation == doi

        Rails.logger.warn err_msg
        Rails.logger.warn resp.body.inspect
        err_msg
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'CitationService fetch', error: e)
        err_msg
      end

      private

      # Convert the EZID response into identifiers
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def process_json(doi:, json:)
        return doi unless json.present? && json['DOI'].present? &&
                          json.fetch('author', []).any? && json['title'].present? &&
                          json['type'].present? && json['publisher'].present?

        date = json.fetch('published-print', json.fetch('content-created', {}))
        return doi unless date.fetch('date-parts', []).any? && date['date-parts'].first.is_a?(Array)

        authors = json['author'].map { |author| "#{author['family']}, #{author['given'][0]}." }.join(', ')
        link = "<a href=\"#{doi}\" target=\"_blank\">#{doi}</a>"

        "#{authors} (#{date['date-parts'].first.first}). \"#{json['title']}\" [#{json['type'].capitalize}]. In #{json['publisher']}. #{link}"
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
