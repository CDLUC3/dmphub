# frozen_string_literal: true

# A JSON representation of a Dsitribution License in the Common Standard format
#json.merge! model_json_base(model: license, skip_hateoas: true)
json.licenseRef license.license_uri
json.startDate license.start_date.to_s
