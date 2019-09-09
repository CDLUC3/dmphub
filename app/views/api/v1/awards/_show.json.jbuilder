# frozen_string_literal: true

# A JSON representation of an Award in the Common Standard format
json.merge! model_json_base(model: award)
json.funder_uri award.funder_uri
json.identifiers award.identifiers do |identifier|
  json.partial! 'api/v1/identifiers/show', identifier: identifier
end
json.funding_statuses award.award_statuses do |award_status|
  json.partial! 'api/v1/award_statuses/show', award_status: award_status
end
