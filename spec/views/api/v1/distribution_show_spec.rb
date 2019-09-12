# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Distribution Show' do

  before(:each) do
    @distribution = create(:distribution, :complete)
    render partial: "api/v1/rda_common_standard/distributions_show.json.jbuilder", locals: { distribution: @distribution }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @distribution, rendered: @json)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@distribution.title)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@distribution.description)
  end

  it 'has a format attribute' do
    expect(@json['format']).to eql(@distribution.format)
  end

  it 'has a byte_size attribute' do
    expect(@json['byte_size']).to eql(@distribution.byte_size)
  end

  it 'has a access_url attribute' do
    expect(@json['access_url']).to eql(@distribution.access_url)
  end

  it 'has a download_url attribute' do
    expect(@json['download_url']).to eql(@distribution.download_url)
  end

  it 'has a data_access attribute' do
    expect(@json['data_access']).to eql(@distribution.data_access)
  end

  it 'has a available_until attribute' do
    expect(@json['available_until']).to eql(@distribution.available_until.to_s)
  end

  it 'has a host attribute' do
    expect(@json['host']['title']).to eql(@distribution.host.title)
  end

  it 'has a licenses attribute' do
    expect(@json['licenses'].length).to eql(@distribution.licenses.length)
  end

end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 20:49:02 UTC",
#   "modified"=>"2019-09-10 20:49:02 UTC",
#   "title"=>"Dolores deleniti deserunt rerum.",
#   "description"=>"Vel et eaque. Inventore quis rem. Aut soluta non.",
#   "format"=>"enim",
#   "byte_size"=>60266422.08,
#   "access_url"=>"http://breitenbergwisoky.biz/oscar",
#   "download_url"=>"http://mcdermott.name/zane.swift",
#   "data_access"=>"shared",
#   "available_until"=>"2019-10-10 20:49:02 UTC",
#   "licenses"=>[{
#     "created"=>"2019-09-10 20:49:02 UTC",
#     "modified"=>"2019-09-10 20:49:02 UTC",
#     "license_ref"=>"http://lang.biz/britney",
#     "start_date"=>"2019-10-10 20:49:02 UTC"
#   }],
#   "host"=>[ << See host_show_spec.rb for an example of its JSON >>]
# }


