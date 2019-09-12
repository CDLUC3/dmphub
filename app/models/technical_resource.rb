# frozen_string_literal: true

# A Dataset Technical Resource
class TechnicalResource < ApplicationRecord

  include Identifiable

  # Associations
  belongs_to :dataset, optional: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? &&
                        json['identifier'].present? &&
                        json['identifier']['value'].present?

      json = json.with_indifferent_access
      tech_resource = new(description: json['description'])
      # Convert the grant_id into an identifier record
      ident = {
        'provenance': provenance.to_s,
        'category': json['identifier'].fetch('category', 'url'),
        'value': json['identifier']['value']
      }
      tech_resource.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      tech_resource
    end

  end
end
