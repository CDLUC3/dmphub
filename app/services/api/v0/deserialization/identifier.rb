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
          def deserialize(provenance:, identifiable:, json: {}, identifiable_type: nil, descriptor: 'is_identified_by')
            return nil unless valid?(json: json) && (identifiable.present? || identifiable_type.present?)

            # If no :identifiable_type was specified, derive it from the :identifiable
            identifiable_type = identifiable.class.name unless identifiable_type.present?
            identifier = find_existing(identifiable: identifiable, identifiable_type: identifiable_type,
                                       json: json)
            return identifier if identifier.present?

            category = type_to_category(json: json)
            return nil unless category.present?

            ::Identifier.find_or_initialize_by(provenance: provenance,
                                               category: category,
                                               descriptor: descriptor,
                                               identifiable: identifiable,
                                               value: json[:identifier])
          end

          private

          # The JSON is valid if both the type and identifier are present
          def valid?(json:)
            return false unless json.present?

            json[:type].present? && json[:identifier].present?
          end

          # Converts the incoming type into a Identifier.categories enum value
          def type_to_category(json: {})
            return nil unless json.present?

            # Attempt to use the specified category
            category = Api::V0::ConversionService.to_identifier_category(rda_category: json[:type])
            return category if ::Identifier.categories.keys.include?(category.to_s)

            # Otherwise derive the category from the value
            Api::V0::ConversionService.identifier_category_from_value(value: json[:identifier])
          end

          # This will find the identifier we are after. If it is an identifier
          # category that requires universal uniqueness (e.g. DOI, URL) it may
          # not match our identifiable!
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def find_existing(identifiable:, identifiable_type: nil, json: {})
            category = type_to_category(json: json)
            return nil unless category.present?

            # If this is a universally unique identifier type (e.g URL or DOI)
            if ::Identifier.requires_universal_uniqueness.map(&:to_s).include?(category)
              ids = ::Identifier.where(value: json[:identifier])
              return nil if ids.empty?

              # Verify we have the right thing by comparing the identifiable or intended identifiable_type
              id = ids.select { |i| i.identifiable == identifiable }.last if identifiable.present?
              id = ids.select { |i| i.identifiable_type == identifiable_type }.last unless id.present?
            else
              # We would never be searching for identifiable with an identifier that is not universally unique
              return nil unless identifiable.present?

              id = ::Identifier.where(identifiable: identifiable, category: category,
                                      value: json[:identifier]).last
            end
            id
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        end
      end
    end
  end
end
