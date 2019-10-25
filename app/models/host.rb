# frozen_string_literal: true

# A Dataset Distribution Host
class Host < ApplicationRecord
  include Identifiable

  # Associations
  belongs_to :distribution, optional: true

  # Validations
  validates :title, presence: true

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, distribution: nil)
      return nil unless json.present? && provenance.present?

      json = json.with_indifferent_access
      host = initialize_from_json(provenance: provenance, json: json, distribution: distribution)

      host.description = json['description']
      host.supports_versioning = ConversionService.yes_no_unknown_to_boolean(json['supportsVersioning'])
      host.backup_type = json['backupType']
      host.backup_frequency = json['backupFrequency']
      host.storage_type = json['storageType']
      host.availability = json['availability']
      host.geo_location = json['geoLocation']

      identifiers_from_json(provenance: provenance, json: json, host: host)
      host
    end

    private

    def initialize_from_json(provenance:, json:, distribution:)
      host = find_by_identifiers(provenance: provenance, json_array: json['hostIds'])
      host = find_or_initialize_by(title: json['title'], distribution: distribution) unless host.present?
      host
    end

    def identifiers_from_json(provenance:, json:, host:)
      json.fetch('hostIds', []).each do |identifier|
        next unless identifier['value'].present?

        ident = {
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value'],
          'descriptor': 'identified_by'
        }
        id = Identifier.from_json(json: ident, provenance: provenance)
        host.identifiers << id unless host.identifiers.include?(id)
      end
    end
  end
end
