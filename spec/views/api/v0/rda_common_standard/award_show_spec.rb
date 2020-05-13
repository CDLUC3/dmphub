# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Award Show' do
  before(:each) do
    @award = create(:award, :complete, organization: create(:organization))
    create(:identifier, category: 'ror', identifiable: @award.organization,
                        value: Faker::Internet.url)
    create(:identifier, category: 'url', identifiable: @award, value: Faker::Internet.url)
    @award.reload

    render partial: 'api/v0/rda_common_standard/awards_show.json.jbuilder',
           locals: { award: @award }
    @json = JSON.parse(rendered)
  end

  it 'has a name attribute' do
    expect(@json['name']).to eql(@award.organization.name)
  end

  it 'has a funder_id attribute' do
    ror = @award.organization.rors.first
    type = Api::V0::ConversionService.to_rda_identifier_category(category: ror.category)
    expect(@json['funder_id']['type']).to eql(type)
    expect(@json['funder_id']['identifier']).to eql(ror.value)
  end

  it 'has a grant_id attribute' do
    grant = @award.urls.first
    type = Api::V0::ConversionService.to_rda_identifier_category(category: grant.category)
    expect(@json['grant_id']['type']).to eql(type)
    expect(@json['grant_id']['identifier']).to eql(grant.value)
  end

  it 'has a funding_status attribute' do
    expect(@json['funding_status']).to eql(@award.status)
  end
end

# Example structure of expected JSON output:
# {
#   "name": "Example Funder",
#   "funder_id": {
#     "type": "ror",
#     "identifier": "https://ror.org/f4t234t"
#   },
#   "grant_id": {
#     "type": "url",
#     "identifier": "https://example-funder.org/awards/1234"
#   },
#   "funding_status": "granted"
# }
