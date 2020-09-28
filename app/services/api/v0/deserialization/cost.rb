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
          #       "description": "The cost of storing the research outputs for preservation"
          #       "value": 10500
          #     }
          def deserialize(provenance:, dmp:, json: {})
            return nil unless valid?(json: json)

            cost = ::Cost.find_or_initialize_by(title: json[:title], data_management_plan: dmp)
            return nil unless cost.present? && cost.valid?

            cost.provenance = provenance unless cost.provenance.present?
            cost.description = json[:description]
            cost.currency_code = json[:currency_code]
            cost.value = json[:value].to_i
            cost
          end
        end
      end
    end
  end
end
