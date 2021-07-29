# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert JSON into a Metadatum
      class Metadatum
        class << self
          # Convert incoming JSON into a Metadatum
          #    {
          #      "description": "Some biological sample standard",
          #      "language": "eng",
          #      "metadata_standard_id": {
          #        "type": "url",
          #        "identifier": "https://some.standard.org/biology"
          #      }
          #    }
          def deserialize(provenance:, dataset:, json: {})
            return nil unless provenance.present? && dataset.present? && valid?(json: json)

            # Try to find the Metadata by the standard id
            metadatum = find_by_identifier(provenance: provenance, json: json)
            metadatum.description = json[:description] if json[:description].present?
            metadatum.language = Api::V0::ConversionService.language(code: json[:language])

            attach_identifier(provenance: provenance, metadatum: metadatum, json: json)
          end

          private

          # The JSON is valid if the Metadatum has a metadata_standard_id
          def valid?(json: {})
            json.present? && json[:metadata_standard_id].present? && json[:metadata_standard_id][:identifier].present?
          end

          # Locate the Metadatum by its Identifier
          def find_by_identifier(provenance:, json: {})
            id_json = json.fetch(:metadata_standard_id, {})
            return nil unless id_json[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(provenance: provenance, identifiable: nil,
                                                                  identifiable_type: 'Metadatum', json: id_json)
            return id.identifiable if id.present? && id.identifiable.is_a?(::Metadatum)

            ::Metadatum.new(provenance: provenance)
          end

          # Marshal the Identifier and attach it to the Metadatum
          def attach_identifier(provenance:, metadatum:, json: {})
            id = json.fetch(:metadata_standard_id, {})
            return metadatum unless id[:identifier].present?

            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: metadatum, json: id, identifiable_type: 'Metadatum'
            )
            metadatum.identifiers << identifier if identifier.present? && identifier.new_record?
            metadatum
          end
        end
      end
    end
  end
end
