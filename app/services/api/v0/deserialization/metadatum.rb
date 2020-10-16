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
            metadata = find_by_identifier(provenance: provenance, json: json)
            return nil unless metadata.present? && metadata.valid?

            attach_identifier(provenance: provenance, dataset: dataset, json: json)
          end

          private

          # The JSON is valid if the Metadatum has a metadata_standard_id
          def valid?(json: {})
            json.present? && json[:metadata_standard_id].present? && json[:metadata_standard_id][:identifier].present?
          end

          # Locate the Metadatum by its Identifier
          def find_by_identifier(provenance:, json: {})
            id = json.fetch(:metadata_standard_id, {})
            return nil unless id[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(provenance: provenance,
                                                                  identifiable: nil,
                                                                  json: json[:metadata_standard_id])
            return id.identifiable if id.present? && id.identifiable.is_a?(Metadatum)

            ::Metadatum.new(provenance: provenance, description: json[:description],
                            language: json[:language])
          end

          # Marshal the Identifier and attach it to the Metadatum
          def attach_identifier(provenance:, metadatum:, json: {})
            id = json.fetch(:metadata_standard_id, {})
            return metadatum unless id[:identifier].present?

            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: metadatum, json: id
            )
            metadatum.identifiers << identifier if identifier.present? && identifier.new_record?
            metadatum
          end
        end
      end
    end
  end
end
