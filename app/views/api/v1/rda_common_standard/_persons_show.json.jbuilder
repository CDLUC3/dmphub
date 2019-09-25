# frozen_string_literal: true

json.ignore_nil!

# A JSON representation of a Person in the Common Standard format
json.merge! model_json_base(model: person, skip_hateoas: true)
json.name person.name
json.mbox person.email

if person.organizations.any?
  json.organizations person.organizations do |organization|
    json.partial! 'api/v1/rda_common_standard/organizations_show',
                  organization: organization
  end
end

if rel == 'primary_contact'
  json.contact_ids person.identifiers do |identifier|
    json.partial! 'api/v1/rda_common_standard/identifiers_show',
                  identifier: identifier
  end
else
  json.user_ids person.identifiers do |identifier|
    json.partial! 'api/v1/rda_common_standard/identifiers_show',
                  identifier: identifier
  end
  json.contributor_type rel
end
