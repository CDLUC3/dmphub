# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert JSON into a Dataset
      class Dataset
        class << self
          # Convert incoming JSON into a Dataset
          #    {
          #      "title": "Cerebral cortex imaging series",
          #      "personal_data": "unknown",
          #      "sensitive_data": "unknown",
          #      "dataset_id": {
          #        "type": "doi",
          #        "identifier": "https://doix.org/10.1234.123abc/y3"
          #      }
          #    }
          def deserialize(provenance:, dmp:, json: {})
            return nil unless provenance.present? && dmp.present? && valid?(json: json)

            # Try to find the Dataset by the identifier
            dataset = find_by_identifier(provenance: provenance, json: json)

            # Try to find the Dataset by title
            dataset = find_by_title(provenance: provenance, json: json) unless dataset.present?
            return nil unless dataset.present? && dataset.valid?

            attach_identifier(provenance: provenance, dataset: dataset, json: json)
          end

          private

          # The JSON is valid if the Dataset has a title
          def valid?(json: {})
            json.present? && json[:title].present?
          end

          # Locate the Dataset by its Identifier
          def find_by_identifier(provenance:, json: {})
            id = json.fetch(:dataset_id, {})
            return nil unless id[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(provenance: provenance,
                                                                  identifiable: nil,
                                                                  json: json)
            id.present? ? id.identifiable : nil
          end

          # Search for the Dataset by it title
          def find_by_title(provenance:, json: {})
            return nil unless json.present? && json[:title].present?

            dataset = ::Dataset.where('LOWER(title) = ?', json[:title].downcase).first
            return dataset if dataset.present?

            # If no good result was found just use the specified title
            ::Dataset.new(provenance: provenance, title: json[:title],
                          description: json[:description], dataset_type: json.fetch(:type, 'dataset'),
                          personal_data: Api::V0::ConversionService.yes_no_unknown_to_boolean(json.fetch(:personal_data, 'unknown')),
                          sensitive_data: Api::V0::ConversionService.yes_no_unknown_to_boolean(json.fetch(:sensitive_data, 'unknown')))
          end

          # Marshal the Identifier and attach it to the Dataset
          def attach_identifier(provenance:, dataset:, json: {})
            id = json.fetch(:dataset_id, {})
            return dataset unless id[:identifier].present?

            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: dataset, json: id
            )
            dataset.identifiers << identifier if identifier.present? && identifier.new_record?
            dataset
          end
        end
      end
    end
  end
end
