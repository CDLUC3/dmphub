# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Description Show' do

  before(:each) do
    @description = create(:project_description)
    render partial: "api/v1/descriptions/show.json.jbuilder", locals: { description: @description }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @description, rendered: @json)
  end

  it 'has a category attribute' do
    expect(@json['category']).to eql(@description.category)
  end

  it 'has a value attribute' do
    expect(@json['value']).to eql(@description.value)
  end

end

# Example structure of expected JSON output:
# {
#   "created_at"=>"2019-09-06 18:11:55 UTC",
#   "category"=>"abstract",
#   "value"=>"Sunt dolorum rerum. Perspiciatis sed consequatur. Ullam deserunt debitis."
# }
