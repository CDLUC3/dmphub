# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Project Show' do

  before(:each) do
    @project = create(:project_with_awards)
    render partial: "api/v1/projects/show.json.jbuilder", locals: { project: @project }
    @json = JSON.parse(rendered)
  end

  it 'has base attributes' do
    validate_base_json_elements(model: @project, rendered: @json)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@project.title)
  end

  it 'has a funding attribute' do
    expect(@json['funding'].length).to eql(@project.awards.length)
  end

end

# Example structure of expected JSON output:
# {
#   "created_at"=>"2019-09-09 16:49:04 UTC",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/projects/1"
#   }],
#   "title"=>"Ur wyogg muaa youw wua mumwa ur roooarrgh nng ooma.",
#   "descriptions"=>[],
#   "funding"=>[ << See award_show_spec.rb for award JSON >> ]
# }
