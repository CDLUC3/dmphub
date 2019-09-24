# frozen_dtring_literal: true

require 'httparty'

class DataciteService

  # Constants referenced in this class can be found in config/initializers/constants.rb
  class << self

    def mint_doi(data_management_plan:)
      json = ActionController::Base.new.render_to_string(
        template: '/datacite/_minter',
        locals: { prefix: DATACITE_SHOULDER, data_management_plan: data_management_plan }
      )
      resp = HTTParty.post(DATACITE_MINT_URI, basic_auth: options, body: json, headers: headers)
      process_error(action: 'mint_doi', response: resp) unless resp.code == :created

      json = JSON.parse(resp.body)
      process_error(
        action: 'mint_doi',
        response: resp,
        msg: 'Unexpected JSON format from Datacite!'
      ) unless json['data'].present? && json['data']['attributes'].present? && json['data']['attributes']['doi'].present?

      json.fetch('data', { 'attributes': { 'doi': nil } }).fetch('attributes', { 'doi': nil })['doi']

    rescue StandardError => se
      Rails.logger.error "DataciteService error during mint_doi: #{se.message}"
      Rails.logger.error "HTTP Status: #{resp.code}" if resp.present? && resp.respond_to?(:code)
      Rails.logger.error "HTTP Body: #{resp.body}" if resp.present? && resp.respond_to?(:body)
      return nil
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
      return nil unless action.present? && response.present?
      Rails.logger.error "DataciteService error during #{action}: HTTP status: #{response.code}"
      Rails.logger.error "DataciteService message: #{msg}" if msg.present?
      Rails.logger.error "DataciteService headers: #{response.headers}"
      Rails.logger.error "DataciteService body: #{response.body}"
    end

  end

end
