# frozen_string_literal: true

require 'httparty'

# Interface to Datacite's API
class DataciteService
  # Constants referenced in this class can be found in config/initializers/constants.rb
  class << self
    def mint_doi(data_management_plan:, provenance:)
      json = json_from_template(provenance: provenance, dmp: data_management_plan)
      resp = HTTParty.post(DATACITE_MINT_URI, basic_auth: options, body: json, headers: headers)
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
      resp = HTTParty.delete("#{DATACITE_SHOW_URI}#{doi}", basic_auth: options, headers: headers)
      return true if %w[204 404].include?(resp.code.to_s)

      process_error(action: 'delete_doi', response: resp)
      Rails.logger.info "Removed the folowing DOI from Datacite: #{doi}"
      false
    end

    def fetch_dois
      url = "#{DATACITE_MINT_URI}?provider-id=#{DATACITE_CLIENT_ID}"
      resp = HTTParty.get(url, basic_auth: options, headers: headers)
      return false unless resp.code == 200
      json = JSON.parse(resp.body)
      dois = json['data'].collect { |d| d['id'] }.uniq
p dois
    end

    private

    def headers
      {
        'User-Agent': Rails.application.class.name.split('::').first,
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/json'
      }
    end

    def options
      { username: DATACITE_CLIENT_ID, password: DATACITE_CLIENT_SECRET }
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
        locals: { prefix: DATACITE_SHOULDER, data_management_plan: dmp, provenance: provenance }
      )
    end
  end
end
