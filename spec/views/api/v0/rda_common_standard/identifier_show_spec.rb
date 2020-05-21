# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Identifier Show' do
  before(:each) do
    @identifier = create(:identifier, identifiable: create(:affiliation))
    render partial: 'api/v0/rda_common_standard/identifiers_show.json.jbuilder',
           locals: { identifier: @identifier }
    @json = JSON.parse(rendered)
  end

  it 'has a category attribute' do
    expected = Api::V0::ConversionService.to_rda_identifier_category(category: @identifier.category)
    expect(@json['type']).to eql(expected)
  end

  it 'has a value attribute' do
    expect(@json['identifier']).to eql(@identifier.value)
  end
end

# Example structure of expected JSON output:
# {
#   "type"=>"doi",
#   "identifier"=>"10.1234/abc123.98zy"
# }
