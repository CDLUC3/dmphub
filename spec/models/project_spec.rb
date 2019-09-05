# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to have_many(:data_management_plans) }
    it { is_expected.to have_many(:awards) }
    it { is_expected.to have_many(:descriptions) }
  end

  it 'factory can produce a valid model' do
    model = create(:project)
    expect(model.valid?).to eql(true)
  end

  context 'instance methods' do
    before(:each) do
      @project = build(:project)
      @project.data_management_plans << build(:data_management_plan)
      @project.awards << build(:award)
      @project.descriptions << build(:project_description)
      @project.save
    end

    describe 'to_json' do
      it 'returns the attributes we expect' do
        json = @project.to_json
        expect(json['title']).to eql(@project.title)
        expect(json['descriptions'].length).to eql(1)
        expect(json['awards'].length).to eql(1)
        expect(json['data_management_plans'].length).to eql(1)
      end
    end
  end
end

# Example of `to_json` output:
# {
#   "created_at"=>"2019-09-04T22:13:58.203Z",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/projects/3"
#   }],
#   "title"=>"Wyogg mumwa huewaa ga wua roooarrgh muaa gwyaaaag!",
#   "data_management_plans"=>[{
#      "rel"=>"described_by",
#      "href"=>"http://localhost:3000/api/v1/data_management_plans/1"
#   }],
#   "awards"=>[{
#     "rel"=>"funded_by",
#     "href"=>"http://localhost:3000/api/v1/awards/1"
#   }],
#   "descriptions"=>[ << See the description_spec.rb for example of its json >> ]
# }
