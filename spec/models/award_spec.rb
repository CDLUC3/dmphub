# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Award, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:funder_uri) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to define_enum_for(:status).with(Award.statuses.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:award)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'awards.json')
    end

    it 'invalid JSON does not create a valid Award instance' do
      validate_invalid_json_to_model(clazz: Award, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Award instance' do
      obj = validate_minimal_json_to_model(clazz: Award, jsons: @jsons)
      expect(obj.funder_uri).to eql(@json['funder_id'])
      expect(obj.status).to eql(@json['funding_status'])
    end

    it 'complete JSON creates a valid Award instance' do
      obj = validate_complete_json_to_model(clazz: Award, jsons: @jsons)
      expect(obj.funder_uri).to eql(@json['funder_id'])
      expect(obj.status).to eql(@json['funding_status'])
      expect(obj.identifiers.first.value).to eql(@json['grant_id'])
    end
  end
end
