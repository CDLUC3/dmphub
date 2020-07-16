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

            # TODO: Implement once we have determined the Dataset model
            nil
          end

          private

          def valid?(json: {})
            json.present? && json[:title].present?
          end
        end
      end
    end
  end
end
