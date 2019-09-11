# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Award Show' do

  before(:each) do
    @award = create(:award, :complete)
    render partial: "api/v1/awards/show.json.jbuilder", locals: { award: @award }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @award, rendered: @json)
  end

  it 'has a funder_uri attribute' do
    expect(@json['funder_id']).to eql(@award.funder_uri)
  end

  it 'has a grant_ids attribute' do
    expect(@json['grant_id']).to eql(@award.identifiers.first.value)
  end

  it 'has a funding_statuses attribute' do
    expect(@json['funding_statuses']).to eql(@award.status)
  end

end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 18:07:57 UTC",
#   "modified"=>"2019-09-10 18:07:57 UTC",
#   "funder_id"=>"http://stehr.com/alva_zulauf",
#   "grant_id"=>"libero",
#   "funding_statuses"=>"applied"
# }
