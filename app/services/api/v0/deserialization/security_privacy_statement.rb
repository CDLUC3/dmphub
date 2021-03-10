# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert JSON into a SecurityPrivacyStatement
      class SecurityPrivacyStatement
        class << self
          # Convert incoming JSON into a SecurityPrivacyStatement
          #    {
          #      "title": "Patient personal information",
          #      "description": ["We are going to anonymize all of the patient personal info"]
          #    }
          def deserialize(provenance:, dataset:, json: {})
            return nil unless provenance.present? && dataset.present? && valid?(json: json)

            # Try to find the SecurityPrivacyStatement by title
            statement = find_by_title(provenance: provenance, dataset: dataset, json: json)

            statement.description = json.fetch(:description, []).join('<br>') if json[:description].present?
            statement
          end

          private

          # The JSON is valid if the SecurityPrivacyStatement has a title
          def valid?(json: {})
            json.present? && json[:title].present?
          end

          # Search for the SecurityPrivacyStatement by it title
          def find_by_title(provenance:, dataset:, json: {})
            return nil unless json.present? && dataset.present? && json[:title].present?

            statement = ::SecurityPrivacyStatement.where(dataset: dataset)
                                                  .where('LOWER(title) = ?', json[:title].downcase).first
            return statement if statement.present?

            # If no good result was found just use the specified title
            ::SecurityPrivacyStatement.new(provenance: provenance, title: json[:title])
          end
        end
      end
    end
  end
end
