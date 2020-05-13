# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Technical Resource Show' do
  before(:each) do
    @technical_resource = create(:technical_resource)
    render partial: 'api/v0/rda_common_standard/technical_resources_show.json.jbuilder',
           locals: { technical_resource: @technical_resource }
    @json = JSON.parse(rendered)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@technical_resource.title)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@technical_resource.description)
  end
end

# Example structure of expected JSON output:
# {
#   "title"=>"An exmaple technical resource",
#   "description"=>"Sed nostrum quis. Nobis nostrum commodi. Nisi a ut."
# }
