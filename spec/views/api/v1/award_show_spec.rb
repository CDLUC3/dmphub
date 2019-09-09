# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Award Show' do

  before(:each) do
    @award = create(:award_with_statuses, status_count: 2)
    render partial: "api/v1/awards/show.json.jbuilder", locals: { award: @award }
    @json = JSON.parse(rendered)
  end

  it 'has base attributes' do
    validate_base_json_elements(model: @award, rendered: @json)
  end

  it 'has a funder_uri attribute' do
    expect(@json['funder_uri']).to eql(@award.funder_uri)
  end

  it 'has a identifiers attribute' do
    expect(@json['identifiers'].length).to eql(@award.identifiers.length)
  end

  it 'has a funding_statuses attribute' do
    expect(@json['funding_statuses'].length).to eql(@award.award_statuses.length)
  end

end

# Example structure of expected JSON output:
# {
#   "created_at"=>"2019-09-06 18:03:27 UTC",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/awards/4"
#   }],
#   "funder_uri"=>"http://hayes.co/esteban",
#   "identifiers"=>[ << See identifier_spec.rb for example of identifier JSON >> ],
#   "funding_statuses"=>[ << See award_status_spec.rb for example of funding_status JSON >> ]
# }
