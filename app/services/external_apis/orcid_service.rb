# frozen_string_literal: true

require 'rest-client'

# Interface to ORCID's API
class OrcidService
  class << self
    # get orcid emails as returned by API
    def email_lookup(orcid:, bearer_token:)
      uri = Rails.configuration.x.orcid.api_uri
      resp = RestClient.get "#{uri}/#{orcid}/email", headers(bearer_token)
      my_info = JSON.parse(resp.body)
      return [] unless my_info['email'].present? && my_info['email'].any?

      my_info['email'].map { |item| (item['email'].blank? ? nil : item['email']) }.compact
    rescue RestClient::Exception => e
      Rails.logger.error(e)
      []
    end

    def employment_lookup(orcid:, bearer_token:)
      uri = Rails.configuration.x.orcid.api_uri
      resp = RestClient.get "#{uri}/#{orcid}/employments", headers(bearer_token)
      my_info = JSON.parse(resp.body)
      return [] unless my_info['employment-summary'].present? && my_info['employment-summary'].any?

      orgs = my_info['employment-summary'].map { |item| (item['organization'].blank? ? nil : item['organization']) }.compact
      orgs = orgs.map { |org| org['name'] }.compact
      orgs.first
    rescue RestClient::Exception => e
      Rails.logger.error(e)
      []
    end

    private

    def headers(token)
      {
        'User-Agent': ApplicationService.application_name,
        'Content-type': 'application/vnd.orcid+json',
        'Authorization': "Bearer #{token}"
      }
    end
  end
end
