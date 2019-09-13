# frozen_string_literal: true

json.ignore_nil!

# A JSON representation of an Organization in the Common Standard format
json.merge! model_json_base(model: organization)
json.name organization.name

if organization.identifiers.any?
  json.identifiers organization.identifiers do |identifier|
    json.partial! 'api/v1/rda_common_standard/identifiers_show',
      identifier: identifier
  end
end
