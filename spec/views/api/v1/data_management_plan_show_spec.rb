# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Data Management Plan Show' do

  before(:each) do
    @data_management_plan = create(:data_management_plan, :complete)
    render partial: "api/v1/data_management_plans/show.json.jbuilder",
           locals: { data_management_plan: @data_management_plan }
    @json = JSON.parse(rendered)
  end

  it 'has base attributes' do
    validate_base_json_elements(model: @data_management_plan, rendered: @json)
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@data_management_plan.title)
  end

  it 'has a language attribute' do
    expect(@json['language']).to eql(@data_management_plan.language)
  end

  it 'has a dmp_ids attribute' do
    expect(@json['dmp_ids'].present?).to eql(true)
  end

  it 'has a descriptions attribute' do
    expect(@json['descriptions'].present?).to eql(true)
  end

  it 'has a ethical_issues_exist attribute' do
    expect(@json['ethical_issues_exist']).to eql(@data_management_plan.has_ethical_issues?)
  end

  it 'has a ethical_issue_descriptions attribute' do
    expect(@json['ethical_issue_descriptions'].present?).to eql(false)
  end

  it 'has a ethical_issue_reports attribute' do
    expect(@json['ethical_issue_reports']).to eql([])
  end

  it 'has a contact attribute' do
    expected = @data_management_plan.person_data_management_plans.select { |p| p.role == 'primary_contact' }
    expect(@json['contact'].first['name']).to eql(expected.first.person.name)
  end

  it 'has a dm_staff attribute' do
    expected = @data_management_plan.person_data_management_plans.select { |p| p.role != 'primary_contact' }
    expect(@json['dm_staff'].length).to eql(expected.length)
  end

  it 'has a project attribute' do
    expect(@json['project'].first['title']).to eql(@data_management_plan.project.title)
  end

  it 'has a datasets attribute' do
    expect(@json['datasets'].first['title']).to eql(@data_management_plan.datasets.first.title)
  end

end

# Example structure of expected JSON output:
# {
#   "created_at"=>"2019-09-09 17:18:08 UTC",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/projects/25"
#   }],
#   "title"=>"Ooma ooma hnn-rowr mumwa muaa roo kabukk hnn-rowr youw wua!",
#   "language"=>"en",
#   "ethical_issues_exist"=>"yes",
#   "dmp_ids"=>[{
#     "created_at"=>"2019-09-09 17:18:08 UTC",
#     "category"=>"doi",
#     "provenance"=>"datacite",
#     "value"=>"10.1234/abc123.zy98"
#   }, {
#     "created_at"=>"2019-09-09 17:18:08 UTC",
#     "category"=>"url",
#     "provenance"=>"dmptool",
#     "value"=>"https://dmptool.org/plans/1234"
#   }],
#   "descriptions"=>[],
#   "ethical_issues_description"=>[],
#   "ethical_issue_reports"=>[],
#   "contact"=>[{
#     "created_at"=>"2019-09-09 17:33:13 UTC",
#     "links"=>[{
#       "rel"=>"self",
#       "href"=>"http://localhost:3000/api/v1/persons/9"
#     }],
#     "name"=>"Darth Vader",
#     "mbox"=>"darth@deathstar.org",
#     "contact_ids"=>[{
#       "create_at"=>"2019-09-09 17:18:08 UTC",
#       "category"=>"orcid",
#       "provenance"=>"orcid",
#       "value"=>"5555555555"
#     }]
#   }],
#   "dm_staff"=>[{
#     "created_at"=>"2019-09-09 17:33:13 UTC",
#     "links"=>[{
#       "rel"=>"self",
#       "href"=>"http://localhost:3000/api/v1/persons/7"
#     }],
#     "name"=>"Bail Organa",
#     "mbox"=>"bail@doomed.planet.com",
#     "user_ids"=>[{
#       "create_at"=>"2019-09-09 17:18:08 UTC",
#       "category"=>"orcid",
#       "provenance"=>"orcid",
#       "value"=>"333333"
#     }],
#     "contributor_type"=>"author"
#   }, {
#     "created_at"=>"2019-09-09 17:33:13 UTC",
#     "links"=>[{
#       "rel"=>"self",
#       "href"=>"http://localhost:3000/api/v1/persons/8"
#     }],
#     "name"=>"Ahsoka Tano",
#     "mbox"=>"ahsoka@jedi.dropbox.com",
#     "user_ids"=>[{
#       "create_at"=>"2019-09-09 17:18:08 UTC",
#       "category"=>"orcid",
#       "provenance"=>"orcid",
#       "value"=>"222222"
#     }],
#     "contributor_type"=>"author"
#   }],
#   "funding"=>[ << See award_show_spec.rb for example of an award JSON >> ],
#   "project"=>[ << See project_show_spec.rb for example of an award JSON >> ],
#   "datasets"=>[ << See dataset_show_spec.rb for example of an award JSON >> ]
# }


