# frozen_string_literal: true

# A JSON representation of a Data Management Plan Cost in the Common Standard format
#json.merge! model_json_base(model: cost, skip_hateoas: true)
json.title cost.title
json.description cost.description
json.value cost.value
json.currencyCode cost.currency_code
