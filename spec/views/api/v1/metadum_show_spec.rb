# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Award Show' do
  before(:each) do
    @metadatum = create(:metadatum, :complete)
    render partial: 'api/v1/rda_common_standard/metadata_show.json.jbuilder', locals: { metadatum: @metadatum }
    @json = JSON.parse(rendered)
  end

  it 'does not have a HATEOAS links attribute' do
    expect(@json['links'].present?).to eql(false)
  end

  it 'has base attributes' do
    validate_created_at_presence(model: @metadatum, rendered: @json)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@metadatum.description)
  end

  it 'has a identifier attribute' do
    expect(@json['identifier']['value']).to eql(@metadatum.identifiers.first.value)
  end

  it 'has a language attribute' do
    expect(@json['language']).to eql(@metadatum.language)
  end
end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 18:51:27 UTC",
#   "modified"=>"2019-09-10 18:51:27 UTC",
#   "identifier"=>{
#     "created"=>"2019-09-06 18:11:55 UTC",
#     "modified"=>"2019-09-06 18:11:55 UTC",
#     "category"=>"url",
#     "provenance"=>"zenodo",
#     "value"=>"http://example.org/dataset/123456789"
#   },
#   "description"=>"Sint recusandae aut. Hic non exercitationem. Totam dolorem exercitationem.",
#   "language"=>"en"
# }
