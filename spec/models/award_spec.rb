# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Award, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:funder_uri) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:award_statuses) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:award)
    expect(model.valid?).to eql(true)
  end

  context 'instance methods' do
    before(:each) do
      @award = build(:award, project: create(:project))
      @award.award_statuses << create(:award_status)
      @award.identifiers << build(:award_identifier)
      @award.save
    end

    describe 'to_json' do
      it 'returns the attributes we expect' do
        json = @award.to_json
        expect(json['funder_uri']).to eql(@award.funder_uri)
        expect(json['project']).to eql(JSON.parse(@award.project.to_hateoas('funded')))
        expect(json['funding_statuses'].length).to eql(1)
        expect(json['identifiers'].length).to eql(1)
      end
    end
  end
end

# Example of `to_json` output:
# {
#   "created_at"=>"2019-09-04T21:11:30.894Z",
#   "funder_uri"=>"http://kohler.org/jerica_schamberger",
#   "project"=>{
#     "rel"=>"funded",
#     "href"=>"http://localhost:3000/api/v1/projects/1"
#   },
#   "funding_statuses"=>[ << See the award_status_spec.rb for example of its json >> ],
#   "identifiers"=>[ << See the identifier_spec.rb for example of its json >> ]
# }
