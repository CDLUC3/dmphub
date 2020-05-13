# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Organization Show' do
  before(:each) do
    @organization = create(:organization, :complete, attrs: { abbreviation: 'foo' })
    render partial: 'api/v0/rda_common_standard/organizations_show.json.jbuilder',
           locals: { organization: @organization }
    @json = JSON.parse(rendered)
  end

  it 'has a name attribute' do
    expect(@json['name']).to eql(@organization.name)
  end

  it 'has an abbreviation attribute' do
    expect(@json['abbreviation']).to eql('foo')
  end

  it 'has a identifiers attribute' do
    orcid = @organization.identifiers.first
    type = Api::V0::ConversionService.to_rda_identifier_category(category: orcid.category)
    expect(@json['affiliation_id']['identifier']).to eql(orcid.value)
    expect(@json['affiliation_id']['type']).to eql(type)
  end
end

# Example structure of expected JSON output:
# {
#   "name"=>"Botsford-Waters",
#   "abbreviation"=>"BW",
#   "identifiers"=>[{
#     "type"=>"grid",
#     "identifier"=>"grid.39084673245986"
#   }]
# }
