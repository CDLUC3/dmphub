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

            # First attempt to look the Host up by its URL
            host = find_by_identifier(json: json)

            # Otherwise look it up by its title and distribution
            host = ::Host.find_or_initialize_by(title: json[:title], distribution: distribution) unless host.present?

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
            host.supports_versioning = Api::V0::ConversionService.yes_no_unknown_to_boolean(json[:support_versioning])
            attach_identifier(provenance: provenance, host: host, json: json)
          end

          private

          # The JSON is valid if the Host has a title and url
          def valid?(json: {})
            json.present? && json[:title].present? && json[:url].present?
          end

          # Locate the Host by its identifier
          def find_by_identifier(json: {})
            return nil unless json[:url].present?

            id = ::Identifier.where(value: json[:url], category: 'url', descriptor: 'is_identified_by').first
            id.present? && id.identifiable.is_a?(Host) ? id.identifiable : nil
          end

          # Marshal the Identifier and attach it
          def attach_identifier(provenance:, host:, json: {})
            return host unless json[:url].present?

            identifier = ::Identifier.find_or_initialize_by(
              provenance: provenance, category: 'url', descriptor: 'is_identified_by', value: json[:url]
            )
            host.identifiers << identifier if identifier.present? && identifier.new_record?
            host
          end
        end
      end
    end
  end
end
