# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Converts RDA Common Standard JSON into a Cost
      class Cost
        class << self
          # Convert the incoming JSON into a Cost
          #     {
          #       "currency_code": "USD",
          #       "title": "Long term server storage",
          #       "description": "The cost of storing the research outputs for preservation",
          #       "value": 10500
          #     }
          def deserialize(provenance:, dmp:, json: {})
            return nil unless provenance.present? && dmp.present? && valid?(json: json)

            cost = ::Cost.find_or_initialize_by(title: json[:title], data_management_plan: dmp)
            return nil unless cost.present?

            cost.provenance = provenance unless cost.provenance.present?
            cost.description = json[:description]
            cost.currency_code = Api::V0::ConversionService.currency_code(code: json[:currency_code])
            cost.value = json[:value].to_f
            cost
          end

          private

          # The JSON is valid if the Dataset has a title
          def valid?(json: {})
            json.present? && json[:title].present? && json[:value].present? && json[:currency_code].present?
          end
        end
      end
    end
  end
end
