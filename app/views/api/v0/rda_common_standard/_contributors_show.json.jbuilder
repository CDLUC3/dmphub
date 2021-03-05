# frozen_string_literal: true

# A JSON representation of a Contributor/Contact in the Common Standard format
json.name contributor.name
json.mbox contributor.email

if contributor.affiliation.present?
  json.affiliation do
    json.partial! 'api/v0/rda_common_standard/affiliations_show',
                  affiliation: contributor.affiliation
  end
end

if rel == 'primary_contact'
  json.contact_id do
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: contributor.orcids.first
  end
else
  json.contributor_id do
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: contributor.orcids.first
  end
  json.role roles
end
