# frozen_string_literal: true

# A JSON representation of a Person in the Common Standard format
json.merge! model_json_base(model: person)
json.name person.name

email = person.identifiers.select { |p| p.category == 'email' }.first&.value
identifiers = person.identifiers.select { |p| p.category != 'email' }

json.mbox email || ''

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
