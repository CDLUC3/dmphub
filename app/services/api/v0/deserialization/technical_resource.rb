# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert JSON into a TechnicalResource
      class TechnicalResource
        class << self
          # Convert incoming JSON into a TechnicalResource
          #    {
          #      "title": "123/45/43/AT",
          #      "description": "MRI scanner"
          #    }
          def deserialize(provenance:, dataset:, json: {})
            return nil unless provenance.present? && dataset.present? && valid?(json: json)

            # Try to find the TechnicalResource by name
            resource = find_by_title(provenance: provenance, dataset: dataset, json: json)
            resource.description = json[:description] if json[:description].present?
            resource
          end

          private

          # The JSON is valid if the TechnicalResource has a name
          def valid?(json: {})
            json.present? && json[:title].present?
          end

          # Search for the SecurityPrivacyStatement by it title
          def find_by_title(provenance:, dataset:, json: {})
            return nil unless json.present? && dataset.present? && json[:title].present?

            resource = ::TechnicalResource.where(dataset: dataset)
                                          .where('LOWER(title) = ?', json[:title].downcase).first
            return resource if resource.present?

            # If no good result was found just use the specified title
            ::TechnicalResource.new(provenance: provenance, title: json[:title])
          end
        end
      end
    end
  end
end
