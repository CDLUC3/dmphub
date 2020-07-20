# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Converts RDA Common Standard JSON into an Affiliation
      class Affiliation
        class << self
          # Convert the incoming JSON into an Affiliation
          #     {
          #       "name": "University of Somewhere",
          #       "abbreviation": "UofS",
          #       "affiliation_id": {
          #         "type": "ror",
          #         "identifier": "https://ror.org/43y4g4"
          #       }
          #     }
          def deserialize(provenance:, json: {})
            return nil unless valid?(json: json)

            # Try to find the Org by the identifier
            affiliation = find_by_identifier(provenance: provenance, json: json)

            # Try to find the Org by name
            affiliation = find_by_name(provenance: provenance, json: json) unless affiliation.present?
            return nil unless affiliation.present? && affiliation.valid?

            affiliation.alternate_names = affiliation.alternate_names << json[:abbreviation]
            attach_identifier(provenance: provenance, affiliation: affiliation, json: json)
          end

          private

          # The JSON is valid if the Affiliation has a name or an identifier
          def valid?(json: {})
            return false unless json.present?

            id = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))[:identifier]
            json[:name].present? || id.present?
          end

          # Locate the Affiliation by its Identifier
          def find_by_identifier(provenance:, json: {})
            id = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            return nil unless id[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(provenance: provenance,
                                                                  identifiable: nil,
                                                                  json: json)
            id.present? ? id.identifiable : nil
          end

          # Search for an Org locally and then externally if not found
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def find_by_name(provenance:, json: {})
            return nil unless json.present? && json[:name].present?

            # Search the DB
            affiliation = ::Affiliation.where('LOWER(name) = ?', json[:name].downcase).first
            return affiliation if affiliation.present?

            # External ROR search
            unless json[:affiliation_id][:type].downcase == 'ror'
              affiliation = ExternalApis::RorService.search(term: json[:name])
              affiliation.provenance = provenance if affiliation.present?
              affiliation.identifiers.each { |id| id.provenance = provenance } if affiliation.present?
              return affiliation if affiliation.present?
            end

            # If no good result was found just use the specified name
            ::Affiliation.new(provenance: provenance, name: json[:name],
                              alternate_names: [], types: [], attrs: {})
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # Marshal the Identifier and attach it to the Affiliation
          def attach_identifier(provenance:, affiliation:, json: {})
            id = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            return affiliation unless id[:identifier].present?

            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: affiliation, json: id
            )
            affiliation.identifiers << identifier if identifier.present? && identifier.new_record?
            affiliation
          end
        end
      end
    end
  end
end
