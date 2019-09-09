# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Funding Status Show' do

  before(:each) do
    @award_status = create(:award_status, award: create(:award, project: create(:project)))

    render partial: "api/v1/award_statuses/show.json.jbuilder",
           locals: { award_status: @award_status }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @award_status, rendered: @json)
  end

  it 'has a status attribute' do
    expect(@json['status']).to eql(@award_status.status)
  end

  it 'has a provenance attribute' do
    expect(@json['provenance']).to eql(@award_status.provenance)
  end

end

# Example structure of expected JSON output:
# {
#   "created_at"=>"2019-09-06 18:01:54 UTC",
#   "status"=>"rejected",
#   "provenance"=>"nsf_awards_api"
# }
