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
      metadatum = initialize_from_json(provenance: provenance, json: json, dataset: dataset)

      ident = {
        'category': json['identifier'].fetch('category', 'url'),
        'value': json['identifier']['value'],
        'descriptor': 'described_by'
      }
      metadatum.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      metadatum
    end

    private

    def initialize_from_json(provenance:, json:, dataset:)
      metadatum = find_by_identifiers(
        provenance: provenance,
        json_array: [json['identifier']]
      )
      unless metadatum.present?
        metadatum = find_or_initialize_by(
          description: json['description'],
          language: json.fetch('language', 'en'),
          dataset: dataset
        )
      end
      metadatum
    end
  end
end
