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

            affiliation.provenance = provenance unless affiliation.provenance.present?
            affiliation.alternate_names << json[:abbreviation] if json[:abbreviation].present?
            affiliation.alternate_names = affiliation.alternate_names.uniq
            affiliation
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
            id_json = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            return nil unless id_json[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(provenance: provenance,
                                                                  identifiable: nil,
                                                                  identifiable_type: 'Affiliation',
                                                                  json: id_json)
            id.present? && id.identifiable.is_a?(::Affiliation) ? id.identifiable : nil
          end

          # Search for an Org locally and then externally if not found
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def find_by_name(provenance:, json: {})
            return nil unless json.present? && json[:name].present?

            # Search both the local DB and the ROR API
            results = AffiliationSelection::SearchService.search_combined(search_term: json[:name])
            return results.first if results.length == 1 && results.first.is_a?(::Affiliation)

            # Grab the closest match - only caring about results that 'contain'
            # the name with preference to those that start with the name
            result = results.select { |r| %w[0 1].include?(r[:weight].to_s) }.first
            affil = AffiliationSelection::HashToAffiliationService.to_affiliation(hash: result) if result.present?

            # If no good result was found just use the specified name
            affil = ::Affiliation.find_or_initialize_by(name: json[:name]) unless affil.present?

            # Attach the alternate names / abbreviations
            affil.alternate_names = [] unless affil.alternate_names.present?
            affil.alternate_names << result[:abbreviation] if result.present?

            affil.types = result.present? ? result.fetch(:types, []) : []
            affil.attrs = result.present? ? result.fetch(:attrs, {}) : {}

            attach_identifiers(provenance: provenance, affiliation: affil, json: json, result: result)
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # Marshal the Identifiers and attach it to the Affiliation
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def attach_identifiers(provenance:, affiliation:, result: {}, json: {})
            return affiliation unless affiliation.new_record?

            ror_prov = Provenance.where(name: 'ror').first

            # First use any identifiers returned by ROR
            if ror_prov.present? && result.present? && (result[:ror].present? || result[:fundref].present?)
              if result[:ror].present?
                affiliation.identifiers << ::Identifier.find_or_initialize_by(
                  provenance: ror_prov, category: 'ror', descriptor: 'is_identified_by',
                  value: "https://ror.org/#{result[:ror]}", identifiable_type: 'Affiliation'
                )
              end
              if result[:fundref].present?
                affiliation.identifiers << ::Identifier.find_or_initialize_by(
                  provenance: ror_prov, category: 'fundref', descriptor: 'is_identified_by',
                  value: "https://api.crossref.org/funders/#{result[:fundref]}",
                  identifiable_type: 'Affiliation'
                )
              end
            end

            # Otherwise take any identifiers passed in the JSON
            id = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            if id.present? && id[:identifier].present?
              identifier = Api::V0::Deserialization::Identifier.deserialize(
                provenance: provenance, identifiable: affiliation, json: id
              )
              affiliation.identifiers << identifier if identifier.present? && identifier.new_record?
            end
            affiliation
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        end
      end
    end
  end
end
