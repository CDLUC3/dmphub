# frozen_string_literal: true

module ExternalApis
  # This service provides an interface to Datacite API.
  class DataciteService < BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.datacite&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.datacite&.api_base_url || super
      end

      def max_pages
        Rails.configuration.x.datacite&.max_pages || super
      end

      def max_results_per_page
        Rails.configuration.x.datacite&.max_results_per_page || super
      end

      def max_redirects
        Rails.configuration.x.datacite&.max_redirects || super
      end

      def active
        Rails.configuration.x.datacite&.active || super
      end

      def client_id
        Rails.configuration.x.datacite&.client_id
      end

      def client_secret
        Rails.configuration.x.datacite&.client_secret
      end

      def mint_path
        Rails.configuration.x.datacite&.mint_path
      end

      def delete_path
        Rails.configuration.x.datacite&.mint_path
      end

      def shoulder
        Rails.configuration.x.datacite&.shoulder
      end

      # Create a new DOI
      # rubocop:disable Metrics/CyclomaticComplexity
      def mint_doi(data_management_plan:, provenance:)
        data = json_from_template(provenance: provenance, dmp: data_management_plan)
        resp = http_post(uri: "#{api_base_url}#{mint_path}", additional_headers: {},
                         data: data, basic_auth: auth, debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'Datacite mint_doi', http_response: resp)
          return nil
        end
        json = JSON.parse(resp.body)
        unless json['data'].present? && json['data']['attributes'].present? && json['data']['attributes']['doi'].present?
          log_error(method: 'Datacite mint_doi', error: StandardError.new('Unexpected JSON format from Datacite!'))
          return nil
        end
        json.fetch('data', 'attributes': { 'doi': nil }).fetch('attributes', 'doi': nil)['doi']
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'Datacite mint_doi', error: e)
        nil
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # Destroy the DOI
      def delete_doi(doi:)
        uri = "#{api_base_url}#{delete_path}"
        resp = http_delete(uri: "#{uri}#{doi}", additional_headers: {},
                           basic_auth: auth, debug: false)
        return true if %w[204 404].include?(resp.code.to_s)

        log_error(action: 'Datacite delete_doi', response: resp)
        false
      end

      # Retrieve all of the DMPHub's DOIs (paginated)
      def fetch_dois
        url = "#{api_base_url}#{index_path}?provider-id=#{client_id}"
        resp = http_get(uri: url, additional_headers: { basic_auth: auth }, debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'Datacite fetch_dois', http_response: resp)
          return []
        end
        json = JSON.parse(resp.body)
        json['data'].collect { |d| d['id'] }.uniq
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'Datacite fetch_dois', error: e)
        []
      end

      private

      def auth
        { username: client_id, password: client_secret }
      end

      def json_from_template(provenance:, dmp:)
        ActionController::Base.new.render_to_string(
          template: '/datacite/_minter',
          locals: {
            prefix: shoulder,
            data_management_plan: dmp,
            provenance: provenance
          }
        )
      end
    end
  end
end
