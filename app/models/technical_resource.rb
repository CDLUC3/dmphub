# frozen_string_literal: true

# A Dataset Technical Resource
class TechnicalResource < ApplicationRecord
  include Identifiable

  # Associations
  belongs_to :dataset, optional: true

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

      resource = find_by_identifiers(
        provenance: provenance,
        json_array: [json['identifier']]
      )

      resource = TechnicalResource.new(dataset: dataset) unless resource.present?

      resource.description = json['description'] if json['description'].present?
      identifier = Identifier.from_json(provenance: provenance, json: json['identifier'])
      resource.identifiers << identifier unless resource.identifiers.include?(identifier)
      resource.save
      resource
    end
  end
end
