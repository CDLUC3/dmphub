# frozen_string_literal: true

# A JSON representation of an Affiliation in the Common Standard format
json.name affiliation.name

json.abbreviation affiliation.attrs[:abbreviation]

if affiliation.rors.any?
  json.affiliation_id do
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: affiliation.rors.first
  end
end
