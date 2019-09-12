# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Project Show' do

  before(:each) do
    @project = create(:project_with_awards)
    render partial: "api/v1/rda_common_standard/projects_show.json.jbuilder", locals: { project: @project }
    @json = JSON.parse(rendered)
  end

  it 'has base attributes' do
    validate_base_json_elements(model: @project, rendered: @json)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@project.title)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@project.description)
  end

  it 'has a start_on attribute' do
    expect(@json['start_on']).to eql(@project.start_on.to_s)
  end

  it 'has a end_on attribute' do
    expect(@json['end_on']).to eql(@project.end_on.to_s)
  end

  it 'has a funding attribute' do
    expect(@json['funding'].length).to eql(@project.awards.length)
  end

end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 20:13:20 UTC",
#   "modified"=>"2019-09-10 20:13:20 UTC",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/projects/5"
#   }],
#   "title"=>"Wyaaaaaa huewaa nng!",
#   "description": "blah blah blah",
#   "start_on"=>"2019-09-15 20:13:20 UTC",
#   "end_on"=>"2020-09-14 20:13:20 UTC",
#   "funding"=>[ << See award_show_spec.rb for award JSON >> ]
# }
