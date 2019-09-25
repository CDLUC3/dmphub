# frozen_string_literal: true

# A Dataset Technical Resource
class TechnicalResource < ApplicationRecord
  include Identifiable

  # Associations
  belongs_to :dataset, optional: true

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, dataset: nil)
      return nil unless json.present? && provenance.present? &&
                        json['identifier'].present? &&
                        json['identifier']['value'].present?

      json = json.with_indifferent_access
      tech_resource = find_by_identifiers(
        provenance: provenance,
        json_array: [json['identifier']]
      )
      unless tech_resource.present?
        tech_resource = find_or_initialize_by(
          description: json['description'],
          dataset: dataset
        )
      end

      ident = {
        'category': json['identifier'].fetch('category', 'url'),
        'value': json['identifier']['value']
      }
      tech_resource.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      tech_resource
    end
  end
end
