# frozen_string_literal: true

# A JSON representation of an Organization in the Common Standard format
# json.merge! model_json_base(model: organization, skip_hateoas: true)
json.name organization.name

json.abbreviation organization.attrs[:abbreviation]

if organization.rors.any?
  json.affiliation_id do
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: organization.rors.first
  end
end
