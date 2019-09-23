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
    def from_json(json:, provenance:, dataset: nil)
      return nil unless json.present? && provenance.present? &&
                        json['identifier'].present? && json['identifier']['value'].present?

      json = json.with_indifferent_access
      metadatum = find_by_identifiers(
        provenance: provenance,
        json_array: [json['identifier']]
      )
      metadatum = find_or_initialize_by(
        description: json['description'],
        language: json.fetch('language', 'en'),
        dataset: dataset
      ) unless metadatum.present?

      ident = {
        'category': json['identifier'].fetch('category', 'url'),
        'value': json['identifier']['value']
      }
      metadatum.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      metadatum
    end

  end
end
