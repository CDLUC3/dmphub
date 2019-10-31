# frozen_string_literal: true

# Hook to add association to Identifier
module Identifiable
  extend ActiveSupport::Concern

  included do
    has_many :identifiers, as: :identifiable, dependent: :destroy

    Identifier.categories.each do |category|
      # Dynamically create methods accessor methods for each Identifier category
      # a method to get specific identifier types (e.g. `orcids`)
      define_method(category[0].downcase.pluralize) do
        identifiers.select { |i| i.category == category[0] }
      end
    end

    class << self
      # Dynamically create methods accessor methods for each Identifier category
      # a scope to find by each Identifier category (e.g. `find_orcid(:value)`)
      Identifier.categories.each do |category|
        define_method("find_by_#{category[0].downcase}") do |value|
          ids = Identifier.where(
            category: category[0],
            identifiable_type: self.name,
            value: value
          ).pluck(:identifiable_id)
          where(id: ids)
        end
      end

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
