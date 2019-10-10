# frozen_string_literal: true

# Hook to add association to Identifier
module Identifiable
  extend ActiveSupport::Concern

  included do
    has_many :identifiers, as: :identifiable, dependent: :destroy

    class << self
      def find_by_identifiers(provenance:, json_array:)
        return nil unless json_array.is_a?(Array) && provenance.present?

        obj = nil
        # Loop through the identifiers and if we find a match then return the
        # asscociated model
        json_array.each do |json|
          next unless json['value'].present? && json['category'].present?

          obj = find_association(provenance: provenance, json: json)
          break if obj.present?
        end
        obj
      end

      private

      def find_association(provenance:, json:)
        identifier = Identifier.where(
          provenance: provenance,
          value: json['value'],
          category: json['category'],
          identifiable_type: name
        ).first
        where(id: identifier.identifiable_id).first if identifier.present?
      end
    end
  end
end
