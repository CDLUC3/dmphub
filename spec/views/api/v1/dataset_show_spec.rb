# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Dataset Show' do

  before(:each) do
    @dataset = create(:dataset, :complete)
    render partial: "api/v1/datasets/show.json.jbuilder", locals: { dataset: @dataset }
    @json = JSON.parse(rendered)
  end

  it 'has base attributes' do
    validate_base_json_elements(model: @dataset, rendered: @json)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@dataset.title)
  end

  it 'has a type attribute' do
    expect(@json['type']).to eql(@dataset.dataset_type)
  end

  it 'has a personal_data attribute' do
    expect(@json['personal_data']).to eql(@dataset.has_personal_data?)
  end

  it 'has a sensitive_data attribute' do
    expect(@json['sensitive_data']).to eql(@dataset.has_sensitive_data?)
  end

  it 'has a identifiers attribute' do
    expect(@json['identifiers'].length).to eql(@dataset.identifiers.length)
  end

  it 'has a descriptions attribute' do
    expect(@json['descriptions'].length).to eql(@dataset.descriptions.length)
  end

end

# Example structure of expected JSON output:
# {
#   "created_at"=>"2019-09-06 19:43:34 UTC",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/datasets/2"
#   }],
#   "title"=>"Youw roooarrgh.",
#   "type"=>"software",
#   "personal_data"=>"unknown",
#   "sensitive_data"=>"unknown",
#   "identifiers"=>[{
#     "created_at"=>"2019-09-06 19:43:34 UTC",
#     "category"=>"url",
#     "provenance"=>"voluptatem",
#     "value"=>"http://example.es"
#   }],
#   "description"=>[{
#     "created_at"=>"2019-09-06 19:43:34 UTC",
#     "category"=>"abstract",
#     "value"=>"Non exercitationem quia. Totam deleniti tempora. Laborum suscipit et."
#   }],
#   "data_quality_assurances"=>[{
#     "created_at"=>"2019-09-06 19:43:34 UTC",
#     "category"=>"quality_assurance",
#     "value"=>"Autem eaque tenetur. Expedita aut aspernatur. Aperiam repellendus laboriosam."
#   }],
#   "preservation_statements"=>[
#     "created_at"=>"2019-09-06 19:43:34 UTC",
#     "category"=>"preservation_statement",
#     "value"=>"Hic cupiditate sit. Voluptatem cum aut. Tenetur temporibus et."
#   }],
#   "keywords"=>[],
#   "languages"=>[],
#   "issued"=>[]
# }
