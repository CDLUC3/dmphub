# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Project Show' do
  before(:each) do
    @project = create(:project, :complete)
    render partial: 'api/v0/rda_common_standard/projects_show.json.jbuilder',
           locals: { project: @project }
    @json = JSON.parse(rendered)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@project.title)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@project.description)
  end

  it 'has a start attribute' do
    expect(@json['start']).to eql(@project.start_on.to_formatted_s(:iso8601))
  end

  it 'has a end attribute' do
    expect(@json['end']).to eql(@project.end_on.to_formatted_s(:iso8601))
  end

  it 'has a funding attribute' do
    expect(@json['funding'].length).to eql(@project.fundings.length)
  end
end

# Example structure of expected JSON output:
# {
#   "title"=>"Wyaaaaaa huewaa nng!",
#   "description": "blah blah blah",
#   "start"=>"2019-09-15 20:13:20 UTC",
#   "end"=>"2020-09-14 20:13:20 UTC",
#   "funding"=>[ << See award_show_spec.rb for award JSON >> ]
# }
