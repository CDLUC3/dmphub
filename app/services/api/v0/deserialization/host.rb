# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert JSON into a Host
      class Host
        class << self
          # Convert incoming JSON into a Host
          #    {
          #      "title": "Dryad",
          #      "availability": "99,5",
          #      "backup_frequency": "weekly",
          #      "backup_type": "tapes",
          #      "certified_with": "coretrustseal",
          #      "description": "Merritt repository via Dryad",
          #      "geo_location": "US",
          #      "pid_system": "doi",
          #      "storage_type": "AWS cloud disk",
          #      "support_versioning": "yes",
          #      "url": "https://datadryad.org"
          #    }
          def deserialize(provenance:, distribution:, json: {})
            return nil unless provenance.present? && distribution.present? && valid?(json: json)

            host = ::Host.find_or_initialize_by(distribution: distribution, url: url)
            host.provenance = provenance unless host.provenance.present?
            host.title = json[:title]
            host.availability = json[:availability]
            host.backup_frequency = json[:backup_frequency]
            host.backup_type = json[:backup_type]
            host.certified_with = json[:certified_with]
            host.description = json[:description]
            host.geo_location = json[:geo_location]
            host.pid_system = json[:pid_system]
            host.storage_type = json[:storage_type]
            host.support_versioning = Api::V0::ConversionService.yes_no_unknown_to_boolean(json[:support_versioning])
            host
          end

          private

          # The JSON is valid if the Host has a title and url
          def valid?(json: {})
            json.present? && json[:title].present? && json[:url].present?
          end
        end
      end
    end
  end
end
