# frozen_string_literal: true

# A JSON representation of an AwardStatus (aka FundingStatus) in the Common Standard format
json.merge! model_json_base(model: award_status, skip_hateoas: true)
json.status award_status.status
json.provenance award_status.provenance
