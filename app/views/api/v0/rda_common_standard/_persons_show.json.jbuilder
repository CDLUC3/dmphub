# frozen_string_literal: true

json.ignore_nil!

# A JSON representation of a Person in the Common Standard format
#json.merge! model_json_base(model: person, skip_hateoas: true)
json.name person.name
json.mbox person.email

if person.organizations.any?
  json.organizations person.organizations do |organization|
    json.partial! 'api/v0/rda_common_standard/organizations_show',
                  organization: organization
  end
end

if rel == 'primary_contact'
  json.contactIds person.identifiers do |identifier|
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: identifier
  end
else
  json.userIds person.identifiers do |identifier|
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: identifier
  end
  json.contributorType rel
end
