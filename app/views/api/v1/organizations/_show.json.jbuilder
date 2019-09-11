# frozen_string_literal: true

# A JSON representation of an Organization in the Common Standard format
json.merge! model_json_base(model: organization)
json.name organization.name
json.identifiers organization.identifiers do |identifier|
  json.partial! 'api/v1/identifiers/show', identifier: identifier
end
