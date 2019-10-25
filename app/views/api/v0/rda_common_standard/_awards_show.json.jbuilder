# frozen_string_literal: true

fundref_doi = award.organization.identifiers.select { |i| i.category == 'doi' }.first

# A JSON representation of an Award in the Common Standard format
#json.merge! model_json_base(model: award, skip_hateoas: true)
json.funderId fundref_doi
json.funderName award.organization.name
json.grantId award.identifiers.first&.value
json.fundingStatus award.status
