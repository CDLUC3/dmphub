# frozen_string_literal: true

require 'base64'

module ExternalApis
  # This service provides an interface to Datacite API.
  class EzidService < BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.ezid&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.ezid&.api_base_url || super
      end

      def active
        Rails.configuration.x.ezid&.active || super
      end

      def login_path
        Rails.configuration.x.ezid&.login_path
      end

      def mint_path
        Rails.configuration.x.ezid&.mint_path
      end

      def delete_path
        Rails.configuration.x.ezid&.mint_path
      end

      def shoulder
        Rails.application.credentials.ezid.fetch(:shoulder, '')
      end

      def creds
        {
          username: Rails.application.credentials.ezid[:username],
          password: Rails.application.credentials.ezid[:password]
        }
      end

      # Create a new DOI
      def mint_doi(data_management_plan:, provenance:)
        data = json_from_template(provenance: provenance, dmp: data_management_plan)

p "EZID:"
p data

        hdrs = { 'Content-Type': 'text/plain', 'Accept': 'text/plain' }
        resp = http_put(uri: "#{api_base_url}#{mint_path}/#{shoulder}.#{doi_suffix}",
                        additional_headers: hdrs, data: data, basic_auth: creds) #, debug: true)

        unless resp.present? && resp.code == 201
          handle_http_failure(method: 'EZID mint_doi', http_response: resp)
          return nil
        end

        process_ezid_response(resp.body)
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'EZID mint_doi', error: e)
        nil
      end

      # Destroy the DOI
      def delete_doi(doi:)
        uri = "#{api_base_url}#{delete_path}"
        resp = http_delete(uri: "#{uri}#{doi}", additional_headers: {},
                           basic_auth: auth, debug: false)
        return true if %w[204 404].include?(resp.code.to_s)

        log_error(action: 'Datacite delete_doi', response: resp)
        false
      end

      private

      # Render the EZID metadata via the text template
      def json_from_template(provenance:, dmp:)
        ActionController::Base.new.render_to_string(
          template: '/ezid/minter',
          locals: {
            prefix: shoulder,
            data_management_plan: dmp,
            provenance: provenance
          }
        )
      end

      # Generate a unique DOI suffix
      def doi_suffix
        doi = ''
        loop do
          doi = SecureRandom.alphanumeric(10)
          break unless Identifier.where(category: 'doi')
                                 .where('value LIKE ?', "%#{doi}").any?
        end
        doi
      end

      # Convert the EZID response into identifiers
      def process_ezid_response(body)
        ids = body.gsub('success: ', '').split(' | ')
        provenance = Provenance.find_or_create_by(name: 'ezid')

        ids.map do |id|
          parts = id.split(':')
          return nil unless parts.length > 1

          Identifier.new(category: parts.first, value: id,
                         provenance: provenance, descriptor: 'is_metadata_for')
        end
      end
    end
  end
end
