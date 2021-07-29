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
          #      "type": "Dataset",
          #      "personal_data": "unknown",
          #      "sensitive_data": "unknown",
          #      "data_quality_assurance": "Our data will be of very high quality!",
          #      "dataset_id": {
          #        "type": "doi",
          #        "identifier": "https://doix.org/10.1234.123abc/y3"
          #      },
          #      "description": "A collection of MRI scans of cerebral cortex for all candidates",
          #      "distribution": [{
          #        "$ref": "SEE Distribution.deserialize! for details"
          #      }],
          #      "issued": "2020-09-13T08:48:12",
          #      "keyword": ["brain", "cerebral", "squishy"],
          #      "language": "eng",
          #      "metadata": [{
          #        "$ref": "SEE Metadatum.deserialize! for details"
          #      }],
          #      "preservation_statement": "We will preserve the data long term.",
          #      "security_and_privacy": [{
          #        "$ref": "SEE SecurityPrivacyStatement.deserialize! for details"
          #      }],
          #      "technical_resource": [{
          #        "$ref": "SEE TechnicalResource.deserialize! for details"
          #      }]
          #    }
          # rubocop:disable Metrics/CyclomaticComplexity
          def deserialize(provenance:, dmp:, json: {})
            return nil unless provenance.present? && dmp.present? && valid?(json: json)

            # Try to find the Dataset by the identifier
            dataset = find_by_identifier(provenance: provenance, json: json)
            # Its ok to update the title if we found this by its id
            dataset.title = json[:title] if dataset.present?

            # Try to find the Dataset by title
            dataset = find_by_title(provenance: provenance, dmp: dmp, json: json) unless dataset.present?
            return nil unless dataset.present? && dataset.valid?

            dataset.personal_data = Api::V0::ConversionService.yes_no_unknown_to_boolean(json[:personal_data])
            dataset.sensitive_data = Api::V0::ConversionService.yes_no_unknown_to_boolean(json[:sensitive_data])
            dataset.description = json[:description]
            dataset.publication_date = json[:issued]
            dataset.preservation_statement = json[:preservation_statement]
            dataset.data_quality_assurance = json[:data_quality_assurance]

            dataset = deserialize_keywords(provenance: provenance, dataset: dataset, json: json)
            dataset = deserialize_metadata(provenance: provenance, dataset: dataset, json: json)
            dataset = deserialize_security_privacy_statements(provenance: provenance, dataset: dataset, json: json)
            dataset = deserialize_technical_resources(provenance: provenance, dataset: dataset, json: json)
            dataset = deserialize_distributions(provenance: provenance, dataset: dataset, json: json)

            attach_identifier(provenance: provenance, dataset: dataset, json: json)
          end
          # rubocop:enable Metrics/CyclomaticComplexity

          private

          # The JSON is valid if the Dataset has a title
          def valid?(json: {})
            json.present? && json[:title].present? && json[:dataset_id].present?
          end

          # Locate the Dataset by its Identifier
          def find_by_identifier(provenance:, json: {})
            id_json = json.fetch(:dataset_id, {})
            return nil unless id_json[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: nil, json: id_json, descriptor: 'is_identified_by',
              identifiable_type: 'Dataset'
            )
            id.present? && id.identifiable.is_a?(::Dataset) ? id.identifiable : nil
          end

          # Search for the Dataset by it title
          def find_by_title(provenance:, dmp:, json: {})
            return nil unless json.present? && dmp.present? && json[:title].present?

            dataset = ::Dataset.where(data_management_plan: dmp)
                               .where('LOWER(title) = ?', json[:title].downcase).first
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
              provenance: provenance, identifiable: dataset, json: id, identifiable_type: 'Dataset'
            )
            dataset.identifiers << identifier if identifier.present? && identifier.new_record?
            dataset
          end

          # Deserialize any Keywords
          def deserialize_keywords(provenance:, dataset:, json:)
            return dataset unless provenance.present? && dataset.present? && json.present?

            dataset.keywords = json.fetch(:keyword, []).map { |k| ::Keyword.find_or_initialize_by(value: k) }
            dataset
          end

          # Deserialize any Metadata
          def deserialize_metadata(provenance:, dataset:, json:)
            return dataset unless json.present? && provenance.present? && dataset.present?

            json.fetch(:metadata, []).each do |metadatum_json|
              metadata = Api::V0::Deserialization::Metadatum.deserialize(
                provenance: provenance, dataset: dataset, json: metadatum_json
              )
              dataset.metadata << metadata if metadata.present?
            end
            dataset
          end

          # Deserialize any Security and Privacy Statements
          def deserialize_security_privacy_statements(provenance:, dataset:, json:)
            return dataset unless json.present? && provenance.present? && dataset.present?

            json.fetch(:security_and_privacy, []).each do |s_and_p_json|
              s_and_p = Api::V0::Deserialization::SecurityPrivacyStatement.deserialize(
                provenance: provenance, dataset: dataset, json: s_and_p_json
              )
              dataset.security_privacy_statements << s_and_p if s_and_p.present?
            end
            dataset
          end

          # Deserialize any Technical Resources
          def deserialize_technical_resources(provenance:, dataset:, json:)
            return dataset unless json.present? && provenance.present? && dataset.present?

            json.fetch(:technical_resource, []).each do |tech_resource_json|
              tech_resource = Api::V0::Deserialization::TechnicalResource.deserialize(
                provenance: provenance, dataset: dataset, json: tech_resource_json
              )
              dataset.technical_resources << tech_resource if tech_resource.present?
            end
            dataset
          end

          # Deserialize any Distributions
          def deserialize_distributions(provenance:, dataset:, json:)
            return dataset unless json.present? && provenance.present? && dataset.present?

            json.fetch(:distribution, []).each do |distribution_json|
              distribution = Api::V0::Deserialization::Distribution.deserialize(
                provenance: provenance, dataset: dataset, json: distribution_json
              )
              dataset.distributions << distribution if distribution.present?
            end
            dataset
          end
        end
      end
    end
  end
end
