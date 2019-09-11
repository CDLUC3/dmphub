# frozen_string_literal: true

# A JSON representation of a Person in the Common Standard format
json.merge! model_json_base(model: person)
json.name person.name
json.mbox person.email
json.organizations person.organizations do |organization|
  json.partial! 'api/v1/organizations/show', organization: organization
end

identifiers = person.identifiers.select { |p| p.category != 'email' }


if rel == 'primary_contact'
  json.contact_ids identifiers do |identifier|
    json.partial! 'api/v1/identifiers/show', identifier: identifier
  end
else
  json.user_ids identifiers do |identifier|
    json.partial! 'api/v1/identifiers/show', identifier: identifier
  end
  json.contributor_type rel
end
