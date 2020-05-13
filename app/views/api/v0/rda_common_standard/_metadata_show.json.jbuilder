# frozen_string_literal: true

# A JSON representation of an Dataset Metdata Entry in the Common Standard format
# json.merge! model_json_base(model: metadatum, skip_hateoas: true)
json.metadata_standard_id do
  json.partial! 'api/v0/rda_common_standard/identifiers_show',
                identifier: metadatum.urls.first
end
json.description metadatum.description
json.language metadatum.language
