# frozen_string_literal: true

# A JSON representation of an Identifier in the Common Standard format
json.merge! model_json_base(model: identifier, skip_hateoas: true)
json.category identifier.category
json.provenance identifier.provenance
json.value identifier.value
