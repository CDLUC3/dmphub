# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Cost Show' do
  before(:each) do
    @cost = create(:cost)
    render partial: 'api/v1/rda_common_standard/costs_show.json.jbuilder', locals: { cost: @cost }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @cost, rendered: @json)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@cost.title)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@cost.description)
  end

  it 'has a value attribute' do
    expect(@json['value']).to eql(@cost.value)
  end

  it 'has a currency_code attribute' do
    expect(@json['currency_code']).to eql(@cost.currency_code)
  end
end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 18:16:01 UTC",
#   "modified"=>"2019-09-10 18:16:01 UTC",
#   "title"=>"Eligendi ea incidunt provident.",
#   "description"=>"Et iure est. Repellat ea voluptas. Aperiam ipsum corrupti.",
#   "value"=>87.03,
#   "currency_code"=>"usd"
# }
