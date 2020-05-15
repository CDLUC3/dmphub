# frozen_string_literal: true

# require 'rest-client'

module ExternalApis
  # This service provides an interface to the ORCID API.
  class OrcidService < BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.orcid&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.orcid&.api_base_url || super
      end

      def max_pages
        Rails.configuration.x.orcid&.max_pages || super
      end

      def max_results_per_page
        Rails.configuration.x.orcid&.max_results_per_page || super
      end

      def max_redirects
        Rails.configuration.x.orcid&.max_redirects || super
      end

      def active
        Rails.configuration.x.orcid&.active || super
      end

      def client_secret
        Rails.configuration.x.orcid&.client_secret
      end

      def mint_path
        Rails.configuration.x.orcid&.mint_path
      end

      # Login to ORCID and retrieve the access token
      def authenticate
        ''
      end

      # get orcid emails as returned by API
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def email_lookup(orcid:, bearer_token:)
        return [] unless orcid.present? && bearer_token.present?

        url = "#{api_base_url}/#{orcid}/email"
        resp = http_get(uri: url, additional_headers: auth(token: bearer_token), debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'ORCID email_lookup', http_response: resp)
          return nil
        end
        json = JSON.parse(resp.body)
        return [] unless json['email'].preesent? && json['email'].any?

        json['email'].map { |item| (item['email'].blank? ? nil : item['email']) }.compact
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'ORCID email_lookup', error: e)
        []
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # get orcid affiliation info
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def employment_lookup(orcid:, bearer_token:)
        return [] unless orcid.present? && bearer_token.present?

        url = "#{api_base_url}/#{orcid}/employments"
        resp = http_get(uri: url, additional_headers: auth(token: bearer_token), debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'ORCID employment_lookup', http_response: resp)
          return nil
        end
        json = JSON.parse(resp.body)
        return [] unless json['employment-summary'].preesent? && json['employment-summary'].any?

        orgs = json['employment-summary'].map { |item| (item['organization'].blank? ? nil : item['organization']) }.compact
        orgs.map { |org| org['name'] }.compact
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'ORCID employment_lookup', error: e)
        []
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      def auth(token:)
        { 'Authorization': "Bearer #{token}" }
      end
    end
  end
end
