# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dataset, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:dataset_type) }
  end

  context 'associations' do
    it { is_expected.to have_many(:descriptions) }
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to belong_to(:data_management_plan) }
  end

  it 'factory can produce a valid model' do
    model = create(:dataset)
    expect(model.valid?).to eql(true)
  end

  context 'instance methods' do
    before(:each) do
      @dataset = build(:dataset)
      @dataset.descriptions << build(:dataset_description)
      @dataset.identifiers << build(:dataset_identifier)
      @dataset.save
    end

    describe 'to_json' do
      it 'returns the attributes we expect' do
        json = @dataset.to_json
        expect(json['title']).to eql(@dataset.title)
        expect(json['dataset_type']).to eql(@dataset.dataset_type)
        expect(json['personal_data']).to eql(@dataset.personal_data?)
        expect(json['sensitive_data']).to eql(@dataset.sensitive_data?)
        expect(json['data_management_plan']).to eql(JSON.parse(@dataset.data_management_plan.to_hateoas('part_of')))
        expect(json['identifiers'].length).to eql(1)
        expect(json['descriptions'].length).to eql(1)
      end
    end
  end
end

# Example of `to_json` output:
# {
#   "created_at"=>"2019-09-04T21:11:30.894Z",
#   "links"=>[
#     {"rel"=>"self", "href"=>"http://localhost:3000/api/v1/datasets/4"}
#   ],
#   "title"=>"Ruh yrroonn yrroonn wua ruh youw huewaa ru huewaa?",
#   "dataset_type"=>"dataset",
#   "personal_data"=>false,
#   "sensitive_data"=>true,
#   "data_management_plan"=>{
#     "rel"=>"part_of",
#     "href"=>"http://localhost:3000/api/v1/data_management_plans/2"
#   },
#   "identifiers"=>[ << See the identifier_spec.rb for example of its json >> ],
#   "descriptions"=>[ << See the description_spec.rb for example of its json >> ]
# }
