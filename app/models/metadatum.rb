# frozen_string_literal: true

# A Dataset Metadata
class Metadatum < ApplicationRecord
  include Authorizable
  include Identifiable

  # Associations
  belongs_to :dataset, optional: true

  # Validations
  validates :language, presence: true

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    super
  end

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json!(provenance:, json:, dataset:)
      return nil unless json.present? && provenance.present? && dataset.present?

      json = json.with_indifferent_access
      return nil unless json['identifier'].present? && json['identifier']['value'].present?

      metadatum = find_by_identifiers(
        provenance: provenance,
        json_array: [json['identifier']]
      )

      metadatum = Metadatum.new(dataset: dataset) unless metadatum.present?

      identifier = Identifier.from_json(provenance: provenance, json: json['identifier'])
      metadatum.identifiers << identifier unless metadatum.identifiers.include?(identifier)
      metadatum.language = json.fetch('language', 'en')
      metadatum.description = json['description'] if json['description'].present?
      metadatum.save
      metadatum
    end
  end
end
