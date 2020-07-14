# frozen_string_literal: true

# A Dataset Distribution Host
class Host < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Associations
  belongs_to :distribution, optional: true

  # Validations
  validates :title, presence: true

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    super
  end

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def from_json!(provenance:, json:, distribution:)
      return nil unless json.present? && provenance.present? && distribution.present?

      json = json.with_indifferent_access
      return nil unless json['title'].present?

      host = find_by_identifiers(
        provenance: provenance,
        json_array: json.fetch('hostIds', [])
      )

      host = Host.find_or_initialize_by(distribution: distribution) unless host.present?
      host.title = json['title']
      host.description = json['description'] if json['description'].present?
      host.supports_versioning = Api::V0::ConversionService.yes_no_unknown_to_boolean(json['supportsVersioning'])
      host.backup_type = json['backupType'] if json['backupType'].present?
      host.backup_frequency = json['backupFrequency'] if json['backupFrequency'].present?
      host.storage_type = json['storageType'] if json['storageType'].present?
      host.availability = json['availability'] if json['availability'].present?
      host.geo_location = json['geoLocation'] if json['geoLocation'].present?

      # Process any other identifiers
      json.fetch('hostIds', []).each do |id|
        identifier = Identifier.from_json(provenance: provenance, json: id)
        host.identifiers << identifier unless host.identifiers.include?(identifier)
      end

      host.save
      host
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
