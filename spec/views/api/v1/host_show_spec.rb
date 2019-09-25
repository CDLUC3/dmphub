# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Host Show' do
  before(:each) do
    @host = create(:host, :complete)
    render partial: 'api/v1/rda_common_standard/hosts_show.json.jbuilder', locals: { host: @host }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @host, rendered: @json)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@host.description)
  end

  it 'has a host_ids attribute' do
    expect(@json['host_ids'].length).to eql(@host.identifiers.length)
  end

  it 'has a supports_versioning attribute' do
    expected = ConversionService.boolean_to_yes_no_unknown(@host.supports_versioning)
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
#   "created"=>"2019-09-10 18:35:11 UTC",
#   "modified"=>"2019-09-10 18:35:11 UTC",
#   "title"=>"Est molestiae delectus aut.",
#   "description"=>"Qui perspiciatis sit. Repellendus soluta nam. Dolor reprehenderit dolorem.",
#   "host_ids"=>[{
#     "created"=>"2019-09-06 18:11:55 UTC",
#     "modified"=>"2019-09-06 18:11:55 UTC",
#     "category"=>"url",
#     "provenance"=>"zenodo",
#     "value"=>"http://example.org/dataset/123456789"
#   }],
#   "supports_versioning"=>"yes",
#   "backup_type"=>"beatae",
#   "backup_frequency"=>"et",
#   "storage_type"=>"est",
#   "availability"=>"earum",
#   "geo_location"=>"Lothal",
#   "certified_with"=>[],
#   "pid_system"=>[]
# }
