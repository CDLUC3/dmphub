# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataManagementPlan, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:language) }
    it { is_expected.to validate_inclusion_of(:ethical_issues).in_array([0, 1, 2]) }
    it { is_expected.to validate_length_of(:datasets) }
  end

  context 'associations' do
    it { is_expected.to have_many(:descriptions) }
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:persons) }
    it { is_expected.to have_many(:datasets) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:oauth_authorization) }
  end

  it 'factory can produce a valid model' do
    model = build(:data_management_plan)
    expect(model.valid?).to eql(true)
  end

  context 'scopes' do
    describe 'for_client' do
      before(:each) do
        @app = create(:doorkeeper_application)
        @dmps = [
          create(:data_management_plan, doorkeeper_application: @app),
          create(:data_management_plan, doorkeeper_application: @app)
        ]
        @other_dmp = create(:data_management_plan)
      end

      it 'returns only the data_management_plans that belong to the client/application' do
        dmps = DataManagementPlan.by_client(client_id: @app.uid).pluck(:data_management_plan_id)
        expect(dmps.length).to eql(2)
        expect(dmps.include?(@other_dmp.id)).to eql(false)
        @dmps.each { |dmp| expect(dmps.include?(dmp.id)).to eql(true) }
      end
    end
  end

  context 'instance methods' do
    before(:each) do
      @dmp = create(:data_management_plan, :complete)
    end

    describe 'primary_contact' do
      it 'returns the primary_contact and only the primary_contact' do
        expect(@dmp.primary_contact.is_a?(PersonDataManagementPlan)).to eql(true)
        expect(@dmp.primary_contact).to eql(PersonDataManagementPlan
          .where(role: 'primary_contact', data_management_plan_id: @dmp.id).first)
      end
    end

    describe 'persons' do
      before(:each) do
        @persons = @dmp.persons
      end
      it 'does not include the primary_contact' do
        expect(@persons.include?(@dmp.primary_contact)).to eql(false)
      end
      it 'includes all non-primary_contact persons' do
        PersonDataManagementPlan.where(data_management_plan_id: @dmp_id).where.not(role: 'primary_contact').each do |p|
          expect(@persons.include?(p)).to eql(true)
        end
      end
    end

    describe 'has_ethical_issues?' do
      it 'returns `no` for a value of 0' do
        @dmp.ethical_issues = 0
        expect(@dmp.has_ethical_issues?).to eql('no')
      end
      it 'returns `yes` for a value of 1' do
        @dmp.ethical_issues = 1
        expect(@dmp.has_ethical_issues?).to eql('yes')
      end
      it 'returns `unknown` for a value of 2' do
        @dmp.ethical_issues = 2
        expect(@dmp.has_ethical_issues?).to eql('unknown')
      end
    end

    describe 'to_json' do

      context 'local json using HATEOAS for associations' do
        it 'returns the expected information' do
          json = @dmp.to_json
          expect(json['title']).to eql(@dmp.title)
          expect(json['language']).to eql(@dmp.language)
          expect(json['ethical_issues']).to eql(@dmp.has_ethical_issues?)
          expect(json['project']).to eql(JSON.parse(@dmp.project.to_hateoas('is_supplement_to')))
          expect(json['contact']).to eql(JSON.parse(@dmp.primary_contact.person.to_hateoas('has_owner')))
          expect(json['descriptions'].first).to eql(@dmp.descriptions.first.to_json)
          expect(json['ethical_issues_descriptions'].first).to eql(@dmp.descriptions.first.to_json)
          expect(json['identifiers'].length).to eql(2)
          expect(json['identifiers'].first).to eql(@dmp.identifiers.first.to_json)
          expect(json['persons'].length).to eql(2)
          expect(json['persons'].first).to eql(JSON.parse(@dmp.persons.first.person.to_hateoas('has_author')))
          expect(json['datasets'].length).to eql(1)
          expect(json['datasets'].first).to eql(JSON.parse(@dmp.datasets.first.to_hateoas('describes')))
        end
      end

      context 'full json' do
        it 'returns the expected information' do
          json = @dmp.to_json(%i[full_json])

p json

          expect(json['title']).to eql(@dmp.title)
          expect(json['language']).to eql(@dmp.language)
          expect(json['ethical_issues']).to eql(@dmp.has_ethical_issues?)
          expect(json['project']).to eql(@dmp.project.to_json(%i[full_json]))
          expect(json['contact']).to eql(@dmp.primary_contact.to_json(%i[full_json]))
          expect(json['descriptions'].length).to eql(1)
          expect(json['descriptions'].first).to eql(@dmp.descriptions.first.to_json)
          expect(json['identifiers'].length).to eql(2)
          expect(json['identifiers'].first).to eql(@dmp.identifiers.first.to_json)
          expect(json['persons'].length).to eql(2)
          expect(json['persons'].first).to eql(@dmp.persons.first.to_json(%i[full_json]))
          expect(json['datasets'].length).to eql(1)
          expect(json['datasets'].first).to eql(@dmp.datasets.first.to_json(%i[full_json]))
        end
      end
    end
  end
end

# Example of `to_json` output (when called from :index):
# {
#   "created_at"=>"2019-09-04T22:23:59.088Z",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/data_management_plans/1"
#   }],
#   "title"=>"Huewaa ooma?",
#   "language"=>"en",
#   "ethical_issues"=>"yes",
#   "project"=>{
#     "rel"=>"is_supplement_to",
#     "href"=>"http://localhost:3000/api/v1/projects/2"
#   },
#   "contact"=>{
#     "rel"=>"has_owner",
#     "href"=>"http://localhost:3000/api/v1/persons/3"
#   },
#   "descriptions"=>[ << See the description_spec.rb for example of its json >> ],
#   "identifiers"=>[ << See the identifier_spec.rb for example of its json >> ],
#   "persons"=>[{
#     "rel"=>"has_author", "href"=>"http://localhost:3000/api/v1/persons/1"
#   }, {
#     "rel"=>"has_author", "href"=>"http://localhost:3000/api/v1/persons/2"
#   }],
#   "datasets"=>[{
#     "rel"=>"describes",
#     "href"=>"http://localhost:3000/api/v1/datasets/1"
#   }]
# }

# Example of `to_json` output (when called from :show):
# {
#   "created_at"=>"2019-09-05T17:57:34.759Z",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/data_management_plans/8"
#   }],
#   "title"=>"Ga muaa wua wyaaaaaa wua youw ooma ma wyaaaaaa.",
#   "language"=>"en",
#   "ethical_issues"=>"unknown",
#   "descriptions"=>[{
#     "created_at"=>"2019-09-05T17:57:34.780Z",
#     "value"=>"Reprehenderit necessitatibus et. Sit aperiam voluptates. Minus qui molestiae.",
#     "category"=>"description"
#    }],
#    "ethical_issues_descriptions"=>[{
#     "created_at"=>"2019-09-05T17:57:34.780Z",
#     "value"=>"Wyogg mumwa huewaa ga wua roooarrgh muaa gwyaaaag!",
#     "category"=>"ethical_issue"
#    }],
#    "ethical_issues_reports": [],
#    "identifiers"=>[{
#      "created_at"=>"2019-09-05T17:57:34.790Z",
#      "value"=>"ipsa",
#      "category"=>"email",
#      "provenance"=>"et"
#    }, {
#      "created_at"=>"2019-09-05T17:57:34.804Z",
#      "value"=>"id",
#      "category"=>"ark",
#      "provenance"=>"unde"
#    }],
#    "project"=>{
#      "created_at"=>"2019-09-05T17:57:34.757Z",
#      "links"=>[{
#        "rel"=>"self",
#        "href"=>"http://localhost:3000/api/v1/projects/9"
#      }],
#      "title"=>"Kabukk ga huewaa youw rarr huewaa ruh muaa?",
#      "descriptions"=>[
#        "created_at"=>"2019-09-05T17:57:34.780Z",
#        "value"=>"Nisi ut eius. Quos dolor reiciendis. Possimus aut adipisci.",
#        "category"=>"description"
#      ],
#      "awards"=>[]
#    },
#    "contact"=>{
#      "created_at"=>"2019-09-05T17:57:34.771Z",
#      "role"=>"primary_contact",
#      "links"=>[{
#        "rel"=>"self",
#        "href"=>"http://localhost:3000/api/v1/persons/6"
#      }],
#      "name"=>"Wedge Antilles"
#    },
#    "persons"=>[{
#      "created_at"=>"2019-09-05T17:57:34.765Z",
#      "role"=>"author",
#      "links"=>[{
#        "rel"=>"self",
#        "href"=>"http://localhost:3000/api/v1/persons/4"
#      }],
#      "name"=>"Sheev Palpatine"
#    }, {
#      "created_at"=>"2019-09-05T17:57:34.768Z",
#      "role"=>"author",
#      "links"=>[{
#        "rel"=>"self",
#        "href"=>"http://localhost:3000/api/v1/persons/5"
#      }],
#      "name"=>"Grand Moff Tarkin"
#    }],
#    "datasets"=>[{
#      "created_at"=>"2019-09-05T17:57:34.760Z",
#      "links"=>[{
#        "rel"=>"self",
#        "href"=>"http://localhost:3000/api/v1/datasets/8"
#      }],
#      "title"=>"Ga muaa wua wyaaaaaa wua youw ooma ma wyaaaaaa.",
#      "dataset_type"=>"dataset",
#      "personal_data"=>false,
#      "sensitive_data"=>false,
#      "identifiers"=>[],
#      "descriptions"=>[]
#    }]
#  }
