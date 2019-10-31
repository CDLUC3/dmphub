# frozen_string_literal: true

# A JSON representation of an Award in the Common Standard format
#json.merge! model_json_base(model: award, skip_hateoas: true)
json.funderId award.organization.dois.first&.value
json.funderName award.organization.name
json.grantId award.identifiers.first&.value
json.fundingStatus award.status
