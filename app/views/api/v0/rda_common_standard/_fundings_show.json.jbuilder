# frozen_string_literal: true

# A JSON representation of an Award in the Common Standard format
json.name funding.affiliation&.name
json.funder_id do
  json.partial! 'api/v0/rda_common_standard/identifiers_show',
                identifier: funding.affiliation&.rors&.first
end
json.funding_status funding.status

grant_id = funding.identifiers.select { |id| id.is_funded_by? }.first
if grant_id.present?
  json.grant_id do
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: grant_id
  end
end

opportunity_id = funding.identifiers.select { |id| id.is_required_by? }.first
if opportunity_id.present? && opportunity_id.value != grant_id&.value
  json.dmproadmap_funding_opportunity_id do
    json.type Api::V0::ConversionService.to_rda_identifier_category(category: opportunity_id.category)
    json.identifier opportunity_id.value
    json.descriptor 'references'
  end
end
