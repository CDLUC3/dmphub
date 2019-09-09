# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Identifier Show' do

  before(:each) do
    @identifier = create(:award_identifier)
    render partial: "api/v1/identifiers/show.json.jbuilder", locals: { identifier: @identifier }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @identifier, rendered: @json)
  end

  it 'has a category attribute' do
    expect(@json['category']).to eql(@identifier.category)
  end

  it 'has a provenance attribute' do
    expect(@json['provenance']).to eql(@identifier.provenance)
  end

  it 'has a value attribute' do
    expect(@json['value']).to eql(@identifier.value)
  end

end

# Example structure of expected JSON output:
# {
#   "created_at"=>"2019-09-06 18:11:55 UTC",
#   "category"=>"doi",
#   "provenance"=>"datacite",
#   "value"=>"10.1234/abc123.98zy"
# }
