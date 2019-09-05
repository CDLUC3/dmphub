# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'associations' do
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:data_management_plans) }
  end

  it 'factory can produce a valid model' do
    model = create(:person)
    expect(model.valid?).to eql(true)
  end

  context 'instance methods' do
    before(:each) do
      @person = create(:person)
      @dmp = create(:person_data_management_plan, person: @person)
      @person.reload
    end

    describe 'to_json' do
      it 'returns the attributes we expect' do
        json = @person.to_json
        expect(json['name']).to eql(@person.name)
        expect(json['data_management_plans'].length).to eql(1)
        expect(json['data_management_plans'].first).to eql(JSON.parse(@dmp.data_management_plan.to_hateoas("#{@dmp.role}_of")))
      end
    end
  end
end

# Example of `to_json` output:
# {
#   "created_at"=>"2019-09-05T15:44:02.995Z",
#   "links"=>[{
#     "rel"=>"self",
#     "href"=>"http://localhost:3000/api/v1/persons/2"
#   }],
#   "name"=>"Sheev Palpatine",
#   "data_management_plans"=>[{
#     "rel"=>"curator_of",
#     "href"=>"http://localhost:3000/api/v1/data_management_plans/1"
#   }]
# }
