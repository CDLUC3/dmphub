# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Converts an RDA Common Standard JSON identifier into an Identifier
      class Identifier
        class << self
          # Convert the incoming JSON into an Identifier
          #    {
          #      "type": "ROR",
          #      "identifier": "https://ror.org/43y4g4"
          #    }
          def deserialize(provenance:, identifiable:, json: {})
            return nil unless identifiable.present? && valid?(json: json)

            identifier = find_existing(provenance: provenance,
                                       identifiable: identifiable,
                                       json: json)
            return identifier if identifier.present?

            category = type_to_category(json: json)
            return nil unless category.present?

            ::Identifier.find_or_initialize_by(provenance: provenance,
                                               category: category,
                                               identifiable: identifiable,
                                               value: json[:identifier])
          end

          private

          # The JSON is valid if both the type and identifier are present
          def valid?(json:)
            return false unless json.present?

            json[:type].present? && json[:identifier].present?
          end

          def type_to_category(json: {})
            return nil unless json.present? && json[:type].present?

            category = Api::V0::ConversionService.to_identifier_category(
              rda_category: json[:type]
            )
            return nil unless ::Identifier.categories.keys.include?(category.to_s)

            category
          end

          # This will find the identifier we are after. If it is an identifier
          # category that requires universal uniqueness (e.g. DOI, URL) it may
          # not match our identifiable!
          def find_existing(provenance:, identifiable:, json:)
            category = type_to_category(json: json)
            return nil unless category.present?

            id = ::Identifier.by_provenance_and_category_and_value(
              provenance: provenance, category: category, value: json[:identifier]
            )
            return nil if id.empty?
            return nil if id.first.identifiable != identifiable && identifiable.present?

            id.first
          end
        end
      end
    end
  end
end
