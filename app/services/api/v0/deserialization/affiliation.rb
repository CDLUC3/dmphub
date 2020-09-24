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
          def find_by_name(provenance:, json: {})
            return nil unless json.present? && json[:name].present?

            # Search the DB
            affiliation = ::Affiliation.where('LOWER(name) = ?', json[:name].downcase).first
            return affiliation if affiliation.present?

            # External ROR search
            unless json.fetch(:affiliation_id, {})[:type]&.downcase == 'ror'
              results = ExternalApis::RorService.search(term: json[:name])

              affiliation = select_ror_candidate(provenance: provenance,
                                                 results: results, json: json)
              return affiliation if affiliation.present?
            end

            # If no good result was found just use the specified name
            ::Affiliation.new(provenance: provenance, name: json[:name],
                              alternate_names: [], types: [], attrs: {})
          end

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

          # rubocop:disable Metrics/CyclomaticComplexity
          def select_ror_candidate(provenance:, results: [], json:)
            identifier = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            return nil unless provenance.present? && results.present? && results.any?

            results = results.select do |result|
              (result[:ror] == identifier[:identifier] && identifier[:type].downcase == 'ROR') ||
                (result[:sort_name].downcase == json[:name].downcase)
            end
            return nil unless results.any?

            ror_candidate_to_affiliation(provenance: provenance, result: results.first)
          end
          # rubocop:enable Metrics/CyclomaticComplexity

          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def ror_candidate_to_affiliation(provenance:, result:)
            return nil unless provenance.present? && result.present?

            affiliation = ::Affiliation.new(name: result[:sort_name])
            if result[:ror].present?
              ror = Api::V0::Deserialization::Identifier.deserialize(
                provenance: provenance, identifiable: affiliation,
                json: { type: 'ror', identifier: result[:ror] }
              )
              affiliation.identifiers << ror if ror.present? && ror.new_record?
            end
            if result[:fundref].present?
              ror = Api::V0::Deserialization::Identifier.deserialize(
                provenance: provenance, identifiable: affiliation,
                json: { type: 'fundref', identifier: result[:fundref] }
              )
              affiliation.identifiers << ror if ror.present? && ror.new_record?
            end
            affiliation
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        end
      end
    end
  end
end
