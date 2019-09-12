# frozen_string_literal: true

# A Dataset Metadata
class Metadatum < ApplicationRecord

  include Identifiable

  # Associations
  belongs_to :dataset, optional: true

  # Validations
  validates :language, presence: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? &&
                        json['identifier'].present? && json['identifier']['value'].present?

      json = json.with_indifferent_access
      metadatum = new(
        language: json.fetch('language', 'en'),
        description: json['description']
      )
      ident = { 'category': 'url', 'value': json['identifier']['value'] }
      metadatum.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      metadatum.valid? ? metadatum : nil
    end

  end
end
