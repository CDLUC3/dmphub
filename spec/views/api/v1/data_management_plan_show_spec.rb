# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 - Data Management Plan Show' do

  before(:each) do
    @data_management_plan = create(:data_management_plan, :complete)
    render partial: "api/v1/rda_common_standard/data_management_plans_show.json.jbuilder",
           locals: { data_management_plan: @data_management_plan }
    @json = JSON.parse(rendered)
  end

  it 'has base attributes' do
    validate_base_json_elements(model: @data_management_plan, rendered: @json)
  end

  it 'has hateoas links attribute' do
    doi = @data_management_plan.identifiers.first
    href = "api_v1_data_management_plans_url"
    expect(@json['links'].present?).to eql(true)
    expect(@json['links'].first['rel']).to eql('self')
    expect(@json['links'].first['href']).to eql("#{Rails.application.routes.url_helpers.send(href)}/#{doi.value}")
  end

  it 'has a title attribute' do
    expect(@json['title']).to eql(@data_management_plan.title)
  end

  it 'has a language attribute' do
    expect(@json['language']).to eql(@data_management_plan.language)
  end

  it 'has a dmp_ids attribute' do
    expect(@json['dmp_ids'].length).to eql(@data_management_plan.identifiers.length)
  end

  it 'has a description attribute' do
    expect(@json['description']).to eql(@data_management_plan.description)
  end

  it 'has a ethical_issues_exist attribute' do
    expected = ConversionService.boolean_to_yes_no_unknown(@data_management_plan.ethical_issues)
    expect(@json['ethical_issues_exist']).to eql(expected)
  end

  it 'has a ethical_issue_description attribute' do
    expect(@json['ethical_issues_description']).to eql(@data_management_plan.ethical_issues_description)
  end

  it 'has a ethical_issue_report attribute' do
    expect(@json['ethical_issues_report']).to eql(@data_management_plan.ethical_issues_report)
  end

  it 'has a contact attribute' do
    expected = @data_management_plan.primary_contact.person
    expect(@json['contact']['name']).to eql(expected.name)
  end

  it 'has a dm_staff attribute' do
    expected = @data_management_plan.persons
    expect(@json['dm_staff'].length).to eql(expected.length)
  end

  it 'has a project attribute' do
    expect(@json['project']['title']).to eql(@data_management_plan.projects.first.title)
  end

  it 'has a datasets attribute' do
    expect(@json['datasets'].first['title']).to eql(@data_management_plan.datasets.first.title)
  end

end

# Example structure of expected JSON output:
# {
#   "created"=>"2019-09-10 22:53:53 UTC",
#   "modified"=>"2019-09-10 22:53:53 UTC",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/data_management_plans/1"
#   }],
#   "title"=>"Roooarrgh kabukk ma ru huewaa?",
#   "description"=>"Dolore assumenda nesciunt. Libero tempora et. Voluptas incidunt rerum.",
#   "language"=>"fr",
#   "ethical_issues_exist"=>"yes",
#   "ethical_issues_description"=>"Nostrum voluptatum quia. Ut et et. Illum voluptatum earum.",
#   "ethical_issues_report"=>"http://maggio.com/sparkle_bernier",
#   "dmp_ids"=>[{
#     "created"=>"2019-09-10 22:19:59 UTC",
#     "modified"=>"2019-09-10 22:19:59 UTC",
#     "category"=>"doi",
#     "provenance"=>"datacite",
#     "value"=>"10.1234/abc123.zy98"
#   }],
#   "contact"=>[{
#     "created"=>"2019-09-10 22:53:53 UTC",
#     "modified"=>"2019-09-10 22:53:53 UTC",
#     "links"=>[{
#       "rel"=>"self",
#       "href"=>"http://localhost:3000/api/v1/persons/1"
#     }],
#     "name"=>"Jabba the Hutt",
#     "mbox"=>"shan@corkery.org",
#     "organizations"=>[{
#       "created"=>"2019-09-10 22:53:53 UTC",
#       "modified"=>"2019-09-10 22:53:53 UTC",
#       "links"=>[{
#         "rel"=>"self",
#         "href"=>"http://localhost:3000/api/v1/organizations/1"
#       }],
#       "name"=>"Beer LLC",
#       "identifiers"=>[{
#         "created"=>"2019-09-10 22:19:59 UTC",
#         "modified"=>"2019-09-10 22:19:59 UTC",
#         "category"=>"grid",
#         "provenance"=>"sunt",
#         "value"=>"grid.49857624596"
#       }]
#     }],
#     "contact_ids"=>[{
#       "created"=>"2019-09-10 22:53:53 UTC",
#       "modified"=>"2019-09-10 22:53:53 UTC",
#       "category"=>"orcid",
#       "provenance"=>"ut",
#       "value"=>"45t353yg4"
#     }]
#   }],
#   "dm_staff"=>[{
#     "created"=>"2019-09-10 22:53:53 UTC",
#     "modified"=>"2019-09-10 22:53:53 UTC",
#     "links"=>[{
#       "rel"=>"self",
#       "href"=>"http://localhost:3000/api/v1/persons/3"
#     }],
#     "name"=>"Darth Vader",
#     "mbox"=>"jake.cronin@mayertlueilwitz.org",
#     "organizations"=>[{
#       "created"=>"2019-09-10 22:53:53 UTC",
#       "modified"=>"2019-09-10 22:53:53 UTC",
#       "links"=>[{
#         "rel"=>"self",
#         "href"=>"http://localhost:3000/api/v1/organizations/2"
#       }],
#       "name"=>"Hintz, Mante and Willms",
#       "identifiers"=>[{
#         "created"=>"2019-09-10 22:19:59 UTC",
#         "modified"=>"2019-09-10 22:19:59 UTC",
#         "category"=>"ror",
#         "provenance"=>"ror_api",
#         "value"=>"http:///ror.example.org/45647474g35"
#       }]
#     }],
#     "user_ids"=>[{
#       "created"=>"2019-09-10 22:53:53 UTC",
#       "modified"=>"2019-09-10 22:53:53 UTC",
#       "category"=>"orcid",
#       "provenance"=>"neque",
#       "value"=>"eos"
#     }],
#     "contributor_type"=>"data_librarian"
#   }],
#   "costs"=>[ << See cost_show_spec.rb for an example of its JSON >> ],
#   "project"=>{ << See project_show.spec.rb for an example of its JSON >> },
#   "datasets"=>[ << See dataset_show_spec.rb for an example of its JSON >> ]
# }
