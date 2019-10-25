# frozen_string_literal: true

# A JSON representation of a Security and Privacy Statement in the Common Standard format
#json.merge! model_json_base(model: technical_resource, skip_hateoas: true)
json.identifier do
  json.partial! 'api/v0/rda_common_standard/identifiers_show',
                identifier: technical_resource.identifiers.first
end
json.description technical_resource.description
