# frozen_string_literal: true

# A JSON representation of an Description in the Common Standard format
json.merge! model_json_base(model: description, skip_hateoas: true)
json.category description.category
json.value description.value
