# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert JSON into a TechnicalResource
      class TechnicalResource
        class << self
          # Convert incoming JSON into a TechnicalResource
          #    {
          #      "name": "123/45/43/AT",
          #      "description": "MRI scanner"
          #    }
          def deserialize(provenance:, dataset:, json: {})
            return nil unless provenance.present? && dataset.present? && valid?(json: json)

            # Try to find the TechnicalResource by name
            find_by_name(provenance: provenance, dataset: dataset, json: json)
          end

          private

          # The JSON is valid if the TechnicalResource has a name
          def valid?(json: {})
            json.present? && json[:name].present?
          end

          # Search for the SecurityPrivacyStatement by it title
          def find_by_name(provenance:, dataset:, json: {})
            return nil unless json.present? && dataset.present? && json[:name].present?

            resource = ::TechnicalResource.where(dataset: dataset)
                                          .where('LOWER(name) = ?', json[:name].downcase).first
            return resource if resource.present?

            # If no good result was found just use the specified title
            ::TechnicalResource.new(provenance: provenance, name: json[:name],
                                    description: json[:description])
          end
        end
      end
    end
  end
end
