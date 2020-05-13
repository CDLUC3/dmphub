# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Award Show' do
  before(:each) do
    @metadatum = create(:metadatum, :complete)
    render partial: 'api/v0/rda_common_standard/metadata_show.json.jbuilder', locals: { metadatum: @metadatum }
    @json = JSON.parse(rendered)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@metadatum.description)
  end

  it 'has a metadata_standard_id attribute' do
    url = @metadatum.identifiers.first
    type = Api::V0::ConversionService.to_rda_identifier_category(category: url.category)
    expect(@json['metadata_standard_id']['type']).to eql(type)
    expect(@json['metadata_standard_id']['identifier']).to eql(url.value)
  end

  it 'has a language attribute' do
    expect(@json['language']).to eql(@metadatum.language)
  end
end

# Example structure of expected JSON output:
# {
#   "metadata_standard_id"=>{
#     "type"=>"url",
#     "identifier"=>"http://example.org/dataset/123456789"
#   },
#   "description"=>"Sint recusandae aut. Hic non exercitationem. Totam dolorem exercitationem.",
#   "language"=>"en"
# }
