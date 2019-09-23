# frozen_string_literal: true

# Hook to add association to Identifier
module Identifiable
  extend ActiveSupport::Concern

  included do
    has_many :identifiers, as: :identifiable

    class << self

      def find_by_identifiers(provenance:, json_array:)
        return nil unless json_array.is_a?(Array) && provenance.present?
        obj = nil

        # Loop through the identifiers and if we find a match then return the
        # asscociated model
        json_array.each do |json|
          next unless json['value'].present? && json['category'].present?

          identifier = Identifier.where(provenance: provenance, value: json['value'],
            category: json['category'], identifiable_type: self.name).first

          obj = self.find(identifier.identifiable_id) if identifier.present?
          break if obj.present?
        end

        return obj
      end

    end

  end
end
