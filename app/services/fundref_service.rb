# frozen_string_literal: true

require 'serrano'
require 'stopwords'

# Service that communicates with the Fundref API
class FundrefService

  class << self

    # Searches the Fundref API for the name
    def find_by_name(name:)
      return nil unless name.present?

      search_words = "#{decontextualize(name).gsub(/\s\s/, ' ')}"
      json = Serrano.funders(query: search_words, limit: 50)
      process_error(action: 'find_by_name', response: json) unless json.fetch('status', '') == 'ok'

      if json.fetch('status', '') == 'ok'
        names = json.fetch('message', {}).fetch('items', []).collect { |i|
          { id: i['uri'], value: i['name'], location: i['location'] }
        }
        sort_and_contextualize(names)
      else
        []
      end
    end

    # Retrives the metadata for the given Fundref DOI
    def find_by_uri(uri:)
      return nil unless uri.present?

      doi = uri.gsub('http://dx.doi.org/', '')
      json = Serrano.funders(ids: [doi]).first
      process_error(action: 'find_by_uri', response: json) unless json.fetch('status', '') == 'ok'

      json.fetch('message', {}).fetch('name', nil)
    rescue StandardError => e
      process_error(action: 'find_by_uri', response: json, msg: e.message)
      nil
    end

    private

    def sort_and_contextualize(array)
      ret = array.sort { |a, b| a[:value]<=>b[:value] }
      names = ret.collect { |h| h[:value] }

      ret.map do |h|
        if names.select { |n| n == h[:value] }.length > 1
          location = h[:location].present? ? " &lt;#{h[:location]}&gt;" : ''
          { id: h[:id], value: "#{h[:value]}#{location}" }
        else
          { id: h[:id], value: h[:value] }
        end
      end
    end

    def decontextualize(value)
      value.split(' <').first
    end

    def headers
      {
        'User-Agent': Rails.application.class.name.split('::').first,
        'Accept': 'application/json'
      }
    end

    def process_error(action:, response:, msg: nil)
      return nil unless action.present?

      Rails.logger.error "FundrefService error during #{action}: HTTP status: #{response&.fetch('status', '')}"
      Rails.logger.error "FundrefService message: #{msg}" if msg.present?
      Rails.logger.error "FundrefService body: #{response}" if response.present?
    end

  end
end
