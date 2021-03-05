# frozen_string_literal: true

require 'rails_helper'

describe 'API V0 - Data Management Plan Show' do
  before(:each) do
    project = create(:project, :complete)
    @data_management_plan = create(:data_management_plan, :complete, project: project)
    @client = create(:api_client)
    render partial: 'api/v0/rda_common_standard/data_management_plans_show.json.jbuilder',
           locals: { data_management_plan: @data_management_plan, client: @client }
    @json = JSON.parse(rendered)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@data_management_plan.title)
  end

  it 'has a language attribute' do
    expect(@json['language']).to eql(@data_management_plan.language)
  end

  it 'has a created attribute' do
    expect(@json['created']).to eql(@data_management_plan.created_at.utc.to_formatted_s(:iso8601))
  end

  it 'has a modified attribute' do
    expect(@json['modified']).to eql(@data_management_plan.updated_at.utc.to_formatted_s(:iso8601))
  end

  it 'has a dmp_id attribute' do
    expect(@json['dmp_id']['identifier']).to eql(@data_management_plan.dois.first.value)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@data_management_plan.description)
  end

  it 'has a ethical_issues_exist attribute' do
    expected = Api::V0::ConversionService.boolean_to_yes_no_unknown(@data_management_plan.ethical_issues)
    expect(@json['ethical_issues_exist']).to eql(expected)
  end

  it 'has a ethical_issue_description attribute' do
    expect(@json['ethical_issues_description']).to eql(@data_management_plan.ethical_issues_description)
  end

  it 'has a ethical_issue_report attribute' do
    expect(@json['ethical_issues_report']).to eql(@data_management_plan.ethical_issues_report)
  end

  it 'has a contact attribute' do
    expected = @data_management_plan.primary_contact
    expect(@json['contact']['name']).to eql(expected.name)
  end

  it 'has a contributor attribute' do
    expected = @data_management_plan.contributors
    expect(@json['contributor'].length).to eql(expected.length)
  end

  it 'has a project attribute' do
    expect(@json['project']['title']).to eql(@data_management_plan.project.title)
  end

  it 'has a dataset attribute' do
    expect(@json['dataset'].first['title']).to eql(@data_management_plan.datasets.first.title)
  end
end

# Example structure of expected JSON output:
# {
#   "title"=>"Roooarrgh kabukk ma ru huewaa?",
#   "description"=>"Dolore assumenda nesciunt. Libero tempora et. Voluptas incidunt rerum.",
#   "language"=>"fr",
#   "created"=>"2019-09-10 22:19:59 UTC",
#   "modified"=>"2019-09-10 22:19:59 UTC",
#   "ethical_issues_exist"=>"yes",
#   "ethical_issues_description"=>"Nostrum voluptatum quia. Ut et et. Illum voluptatum earum.",
#   "ethical_issues_report"=>"http://maggio.com/sparkle_bernier",
#   "dmp_id"=>{
#     "type"=>"DOI",
#     "identifier"=>"10.1234/abc123.zy98"
#   }],
#   "contact"=>{ << See the person_show view for an example >> },
#   "contributor"=>[ << See the person_show view for an example >> ],
#   "cost"=>[ << See cost_show_spec.rb for an example of its JSON >> ],
#   "project"=>{ << See project_show.spec.rb for an example of its JSON >> },
#   "dataset"=>[ << See dataset_show_spec.rb for an example of its JSON >> ]
# }
