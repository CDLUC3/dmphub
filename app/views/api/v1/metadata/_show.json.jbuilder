# frozen_string_literal: true

# A JSON representation of an Dataset Metdata Entry in the Common Standard format
json.merge! model_json_base(model: metadatum, skip_hateoas: true)
json.identifier do
  json.partial! 'api/v1/identifiers/show', identifier: metadatum.identifiers.first
end
json.description metadatum.description
json.language metadatum.language
