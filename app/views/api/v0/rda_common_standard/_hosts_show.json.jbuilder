# frozen_string_literal: true

# A JSON representation of a Dataset in the Common Standard format
# json.merge! model_json_base(model: host, skip_hateoas: true)
json.title host.title
json.description host.description
json.url host.urls.first&.value
json.supports_versioning Api::V0::ConversionService.boolean_to_yes_no_unknown(host.supports_versioning)
json.backup_type host.backup_type
json.backup_frequency host.backup_frequency
json.storage_type host.storage_type
json.availability host.availability
json.geo_location host.geo_location

# TODO: Implement these later
json.certified_with []
json.pid_system []
