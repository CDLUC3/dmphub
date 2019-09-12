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
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present?
      json = json.with_indifferent_access
      host = new(
        title: json.fetch('title', ''),
        description: json.fetch('description', ''),
        supports_versioning: ConversionService.yes_no_unknown_to_boolean(json['supports_versioning']),
        backup_type: json['backup_type'],
        backup_frequency: json['backup_frequency'],
        storage_type: json['storage_type'],
        availability: json['availability'],
        geo_location: json['geo_location']
      )
      return host unless host.valid? && json['host_ids'].present?

      # Convert the dmp_ids into identifier records
      json.fetch('host_ids', []).each do |dmp_id|
        next unless dmp_id['value'].present?
        ident = {
          'provenance': provenance.to_s,
          'category': dmp_id.fetch('category', 'url'),
          'value': dmp_id['value']
        }
        host.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      end
      host
    end

  end
end
