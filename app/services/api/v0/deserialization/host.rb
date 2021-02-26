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
          #      "url": "https://datadryad.org",
          #      "dmproadmap_host_id": {
          #        "type": "url",
          #        "identifier": "https://www.re3data.org/api/v1/repository/r3d100000044"
          #      }
          #    }
          def deserialize(provenance:, json: {})
            return nil unless provenance.present? && valid?(json: json)

            # First attempt to look the Host up by its URL
            host = find_by_identifier(provenance: provenance, json: json)

            # Otherwise look it up by its title
            host = ::Host.find_or_initialize_by(title: json[:title]) unless host.present?

            host.provenance = provenance unless host.provenance.present?
            host.availability = json[:availability]
            host.backup_frequency = json[:backup_frequency]
            host.backup_type = json[:backup_type]
            host.certified_with = json[:certified_with]
            host.description = json[:description]
            host.geo_location = json[:geo_location]
            host.pid_system = json[:pid_system]
            host.storage_type = json[:storage_type]
            host.supports_versioning = Api::V0::ConversionService.yes_no_unknown_to_boolean(json[:support_versioning])

            host = attach_host_landing_page(provenance: provenance, host: host, url: json[:url])
            attach_identifier(provenance: provenance, host: host, json: json)
          end

          private

          # The JSON is valid if the Host has a title and url
          def valid?(json: {})
            json.present? && json[:title].present? && json[:url].present?
          end

          # Locate the Host by its identifier
          def find_by_identifier(provenance:, json: {})
            return nil unless json[:url].present? || json[:dmproadmap_host_id].present?

            # First try to find the Host by its host_id if applicable
            id = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: nil, json: json.fetch(:dmproadmap_host_id, {})
            )
            return id.identifiable if id.present? && id.identifiable.is_a?(Host)

            # Otherwise try to find the Host by its URL
            id = ::Identifier.where(value: json[:url], category: 'url', descriptor: 'is_identified_by').first
            id.present? && id.identifiable.is_a?(Host) ? id.identifiable : nil
          end

          # Marshal the URL as an Identifier and attach it
          def attach_host_landing_page(provenance:, host:, url:)
            return host unless url.present?

            identifier = ::Identifier.find_or_initialize_by(
              provenance: provenance, category: 'url', descriptor: 'is_identified_by', value: url
            )
            host.identifiers << identifier if identifier.present? && identifier.new_record?
            host
          end

          # Marshal the Identifier and attach it to the Host
          def attach_identifier(provenance:, host:, json: {})
            id = json.fetch(:dmproadmap_host_id, {})
            return host unless id[:identifier].present?

            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: host, json: id
            )
            host.identifiers << identifier if identifier.present? && identifier.new_record?
            host
          end
        end
      end
    end
  end
end
