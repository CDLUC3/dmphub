# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Technical Resource Show' do

  before(:each) do
    @technical_resource = create(:technical_resource, :complete)
    render partial: "api/v1/technical_resources/show.json.jbuilder",
           locals: { technical_resource: @technical_resource }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @technical_resource, rendered: @json)
  end

  it 'has a identifier attribute' do
    expect(@json['identifier']['value']).to eql(@technical_resource.identifiers.first.value)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@technical_resource.description)
  end

end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 20:29:36 UTC",
#   "modified"=>"2019-09-10 20:29:36 UTC",
#   "identifier"=>{
#     "created"=>"2019-09-10 20:29:36 UTC",
#     "modified"=>"2019-09-10 20:29:36 UTC",
#     "category"=>"url",
#     "provenance"=>"qui",
#     "value"=>"http://example.org/resource/456245"
#   },
#   "description"=>"Sed nostrum quis. Nobis nostrum commodi. Nisi a ut."
# }
