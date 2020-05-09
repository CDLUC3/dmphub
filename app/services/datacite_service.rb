# frozen_string_literal: true

require 'httparty'

# Interface to Datacite's API
class DataciteService
  # Constants referenced in this class can be found in config/initializers/constants.rb
  class << self
    def mint_doi(data_management_plan:, provenance:)
      json = json_from_template(provenance: provenance, dmp: data_management_plan)
      uri = Rails.configuration.x.datacite.mint_uri
      resp = HTTParty.post(uri, basic_auth: options, body: json, headers: headers)
      process_error(action: 'mint_doi', response: resp) unless resp.code == 201

      json = JSON.parse(resp.body)
      unless json['data'].present? && json['data']['attributes'].present? && json['data']['attributes']['doi'].present?
        process_error(action: 'mint_doi', response: resp, msg: 'Unexpected JSON format from Datacite!')
      end

      json.fetch('data', 'attributes': { 'doi': nil }).fetch('attributes', 'doi': nil)['doi']
    rescue StandardError => e
      process_error(action: 'mint_doi', response: resp, msg: e.message)
      nil
    end

    def delete_doi(doi:)
      uri = Rails.configuration.x.datacite.show_uri
      resp = HTTParty.delete("#{uri}#{doi}", basic_auth: options, headers: headers)
      return true if %w[204 404].include?(resp.code.to_s)

      process_error(action: 'delete_doi', response: resp)
      Rails.logger.info "Removed the folowing DOI from Datacite: #{doi}"
      false
    end

    def fetch_dois
      uri = Rails.configuration.x.datacite.mint_uri
      id = Rails.configuration.x.datacite.client_id
      url = "#{uri}?provider-id=#{id}"
      resp = HTTParty.get(url, basic_auth: options, headers: headers)
      return false unless resp.code == 200

      json = JSON.parse(resp.body)
      json['data'].collect { |d| d['id'] }.uniq
    end

    private

    def headers
      {
        'User-Agent': ApplicationService.application_name,
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/json'
      }
    end

    def options
      {
        username: Rails.configuration.x.datacite.client_id,
        password: Rails.configuration.x.datacite.client_secret
      }
    end

    def process_error(action:, response:, msg: nil)
      return nil unless action.present?

      Rails.logger.error "DataciteService error during #{action}: HTTP status: #{response&.code}"
      Rails.logger.error "DataciteService message: #{msg}" if msg.present?
      Rails.logger.error "DataciteService headers: #{response.headers}" if response.present?
      Rails.logger.error "DataciteService body: #{response.body}" if response.present?
    end

    def json_from_template(provenance:, dmp:)
      ActionController::Base.new.render_to_string(
        template: '/datacite/_minter',
        locals: {
          prefix: Rails.configuration.x.datacite.shoulder,
          data_management_plan: dmp,
          provenance: provenance
        }
      )
    end
  end
end
