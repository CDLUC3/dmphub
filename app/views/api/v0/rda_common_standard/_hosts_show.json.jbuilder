# frozen_string_literal: true

# A JSON representation of a Dataset in the Common Standard format
json.merge! model_json_base(model: host, skip_hateoas: true)
json.title host.title
json.description host.description

if host.identifiers.any?
  json.hostIds host.identifiers do |identifier|
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: identifier
  end
end

json.supportsVersioning ConversionService.boolean_to_yes_no_unknown(host.supports_versioning)

json.backupType host.backup_type
json.backupFrequency host.backup_frequency
json.storageType host.storage_type
json.availability host.availability
json.geoLocation host.geo_location

# TODO: Implement these later
json.certifiedWith []
json.pidSystem []
