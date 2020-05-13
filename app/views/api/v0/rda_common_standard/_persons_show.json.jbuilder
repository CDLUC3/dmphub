# frozen_string_literal: true

# A JSON representation of a Person in the Common Standard format
# json.merge! model_json_base(model: person, skip_hateoas: true)
json.name person.name
json.mbox person.email

if person.organizations.any?
  json.affiliation do
    json.partial! 'api/v0/rda_common_standard/organizations_show',
                  organization: person.organizations.order(created_at: :desc).first
  end
end

if rel == 'primary_contact'
  json.contact_id do
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: person.orcids.first
  end
else
  json.contributor_id do
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: person.orcids.first
  end
  json.roles person.credits do |role|
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: role
  end
end
