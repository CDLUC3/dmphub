# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Organization Show' do

  before(:each) do
    @organization = create(:organization, :complete)
    render partial: 'api/v1/rda_common_standard/organizations_show.json.jbuilder',
           locals: { organization: @organization }
    @json = JSON.parse(rendered)
  end

  it 'has base attributes' do
    validate_base_json_elements(model: @organization, rendered: @json)
  end

  it 'has a name attribute' do
    expect(@json['name']).to eql(@organization.name)
  end

  it 'has a identifiers attribute' do
    expect(@json['identifiers'].length).to eql(@organization.identifiers.length)
  end

end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 20:01:08 UTC",
#   "modified"=>"2019-09-10 20:01:08 UTC",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/organizations/3"
#   }],
#   "name"=>"Botsford-Waters",
#   "identifiers"=>[{
#     "created"=>"2019-09-10 20:01:08 UTC",
#     "modified"=>"2019-09-10 20:01:08 UTC",
#     "category"=>"grid",
#     "provenance"=>"ror_api",
#     "value"=>"grid.39084673245986"
#   }]
# }

