# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert JSON into a Distribution
      class Distribution
        class << self
          # Convert incoming JSON into a Distribution
          #    {
          #      "title": "Open access copy of Dataset A",
          #      "access_url": "https://secure.repo.org/dataset/12345",
          #      "available_until": "2050-01-01",
          #      "byte_size": 10000,
          #      "data_access": "open",
          #      "description": "Open access copy of the dataset",
          #      "download_url": "https://secure.repo.org/dataset/12345.pdf",
          #      "format": "image/tiff",
          #      "host": {
          #        "$ref": "SEE Host.deserialize! for details"
          #      },
          #      "license": [{
          #        "$ref": "SEE License.deserialize! for details"
          #      }]
          #    }
          def deserialize(provenance:, dataset:, json: {})
            return nil unless provenance.present? && dataset.present? && valid?(json: json)

            # Try to find the Distribution by the identifier
            distribution = find_by_urls(json: json)

            host = Api::V0::Deserialization::Host.deserialize(
              provenance: provenance, json: json.fetch(:host, {})
            )
            # Try to find the Distribution by title
            distribution = find_by_title(provenance: provenance, host: host, json: json) unless distribution.present?
            return nil unless distribution.present?

            distribution.host = host
            distribution.available_until = json[:available_until]
            distribution.byte_size = json[:byte_size].to_i
            distribution.data_access = json[:data_access]
            distribution.description = json[:description]
            distribution.format = json[:format]
            distribution.access_url = json[:access_url]
            distribution.download_url = json[:download_url]

            deserialize_licenses(provenance: provenance, distribution: distribution, json: json)
          end

          private

          # The JSON is valid if the Distribution has a title
          def valid?(json: {})
            json.present? && json[:title].present? && json[:data_access].present?
          end

          # Locate the Distribution by its Identifier
          def find_by_urls(json: {})
            return nil unless json.present? && (json[:access_url].present? || json[:download_url].present?)

            ::Distribution.where(access_url: json[:access_url])
                          .or(::Distribution.where(download_url: json[:download_url]))
                          .first
          end

          # Search for the Distribution by it title
          def find_by_title(provenance:, host:, json: {})
            return nil unless json.present? && json[:title].present?

            distribution = ::Distribution.where(host: host)
                                         .where('LOWER(title) = ?', json[:title].downcase).first
            return distribution if distribution.present?

            # If no good result was found just use the specified title
            ::Distribution.new(provenance: provenance, title: json[:title],
                               access_url: json[:access_url], download_url: json[:download_url])
          end

          # Deserialize any Licenses
          def deserialize_licenses(provenance:, distribution:, json:)
            json.fetch(:license, []).each do |license_json|
              license = Api::V0::Deserialization::License.deserialize(
                provenance: provenance, distribution: distribution, json: license_json
              )
              distribution.licenses << license if license.present?
            end
            distribution
          end
        end
      end
    end
  end
end
