# frozen_string_literal: true

# A JSON representation of an Award in the Common Standard format
json.merge! model_json_base(model: award, skip_hateoas: true)
json.funder_id award.funder_uri
json.grant_id award.identifiers.first&.value
json.funding_status award.status
