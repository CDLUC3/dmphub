# frozen_string_literal: true

# A JSON representation of a Dsitribution License in the Common Standard format
json.merge! model_json_base(model: license, skip_hateoas: true)
json.license_ref license.license_uri
json.start_date license.start_date.to_s
