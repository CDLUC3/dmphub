# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Dataset Show' do
  before(:each) do
    @dataset = create(:dataset, :complete)
    render partial: 'api/v0/rda_common_standard/datasets_show.json.jbuilder', locals: { dataset: @dataset }
    @json = JSON.parse(rendered)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@dataset.title)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@dataset.description)
  end

  it 'has a type attribute' do
    expect(@json['type']).to eql(@dataset.dataset_type)
  end

  it 'has a issued attribute' do
    expect(@json['issued']).to eql(@dataset.publication_date.to_formatted_s(:iso8601))
  end

  it 'has a language attribute' do
    expect(@json['language']).to eql(@dataset.language)
  end

  it 'has a personal_data attribute' do
    expected = Api::V0::ConversionService.boolean_to_yes_no_unknown(@dataset.personal_data)
    expect(@json['personal_data']).to eql(expected)
  end

  it 'has a sensitive_data attribute' do
    expected = Api::V0::ConversionService.boolean_to_yes_no_unknown(@dataset.sensitive_data)
    expect(@json['sensitive_data']).to eql(expected)
  end

  it 'has a data_quality_assurance attribute' do
    expect(@json['data_quality_assurance']).to eql(@dataset.data_quality_assurance)
  end

  it 'has a preservation_statement attribute' do
    expect(@json['preservation_statement']).to eql(@dataset.preservation_statement)
  end

  it 'has a dataset_ids attribute' do
    expect(@json['dataset_id']['identifier']).to eql(@dataset.identifiers.first.value)
  end

  xit 'has a keywords attribute' do
    expect(@json['keyword'].length).to eql(@dataset.keywords.length)
  end

  it 'has a security_and_privacy_statements attribute' do
    expect(@json['security_and_privacy'].length).to eql(@dataset.security_privacy_statements.length)
  end

  it 'has a technical_resources attribute' do
    expect(@json['technical_resource'].length).to eql(@dataset.technical_resources.length)
  end

  it 'has a metadata attribute' do
    expect(@json['metadata'].length).to eql(@dataset.metadata.length)
  end
end

# Example structure of expected JSON output:
# {
#   "title"=>"Roooarrgh.",
#   "description"=>"Enim et vel. Tenetur culpa et. Voluptates eveniet non.",
#   "type"=>"software",
#   "language"=>"en",
#   "issued"=>"2019-09-10 22:19:59 UTC",
#   "personal_data"=>"yes",
#   "sensitive_data"=>"unknown",
#   "data_quality_assurance"=>"Incidunt eius molestias. Ab ipsum ullam. Eos maxime omnis.",
#   "preservation_statement"=>"Perferendis eligendi in. Distinctio harum iste. Dolores officia in.",
#   "identifiers"=>[{
#     "type"=>"URL",
#     "identifier"=>"ea"
#   }],
#   "keywords"=>["minima","officia"],
#   "security_and_privacy_statements"=>[ << See security_privacy_statement_show_spec.rb for example of JSON >> ],
#   "technical_resources"=>[ << See technical_resource_show_spec.rb for example of JSON >> ],
#   "metadata"=>[ << See metadata_show_spec.rb for example of JSON >> ],
#   "distributions"=>[ << See distribution_show_spec.rb for an example of its JSON >> ]
# }
