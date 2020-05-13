# frozen_string_literal: true

# A JSON representation of an Award in the Common Standard format
json.name award.organization&.name
json.funder_id do
  json.partial! 'api/v0/rda_common_standard/identifiers_show',
                identifier: award.organization&.rors&.first
end
json.grant_id do
  json.partial! 'api/v0/rda_common_standard/identifiers_show',
                identifier: award.urls&.first
end
json.funding_status award.status
