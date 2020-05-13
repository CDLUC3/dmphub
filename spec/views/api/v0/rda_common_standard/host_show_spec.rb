# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Host Show' do
  before(:each) do
    @host = create(:host, :complete)
    render partial: 'api/v0/rda_common_standard/hosts_show.json.jbuilder', locals: { host: @host }
    @json = JSON.parse(rendered)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@host.description)
  end

  it 'has a url attribute' do
    expect(@json['url']).to eql(@host.urls.first.value)
  end

  it 'has a supports_versioning attribute' do
    expected = Api::V0::ConversionService.boolean_to_yes_no_unknown(@host.supports_versioning)
    expect(@json['supports_versioning']).to eql(expected)
  end

  it 'has a backup_type attribute' do
    expect(@json['backup_type']).to eql(@host.backup_type)
  end

  it 'has a backup_frequency attribute' do
    expect(@json['backup_frequency']).to eql(@host.backup_frequency)
  end

  it 'has a storage_type attribute' do
    expect(@json['storage_type']).to eql(@host.storage_type)
  end

  it 'has a availability attribute' do
    expect(@json['availability']).to eql(@host.availability)
  end

  it 'has a certified_with attribute' do
    expect(@json['certified_with']).to eql([])
  end

  it 'has a geo_location attribute' do
    expect(@json['geo_location']).to eql(@host.geo_location)
  end

  it 'has a pid_system attribute' do
    expect(@json['pid_system']).to eql([])
  end
end

# Example structure of expected JSON output:
# {
#   "title"=>"Est molestiae delectus aut.",
#   "description"=>"Qui perspiciatis sit. Repellendus soluta nam. Dolor reprehenderit dolorem.",
#   "url"=>"http://example.org/dataset/123456789",
#   "supports_versioning"=>"yes",
#   "backup_type"=>"beatae",
#   "backup_frequency"=>"et",
#   "storage_type"=>"est",
#   "availability"=>"earum",
#   "geo_location"=>"Lothal",
#   "certified_with"=>[],
#   "pid_system"=>[]
# }
