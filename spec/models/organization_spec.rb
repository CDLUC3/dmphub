# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'associations' do
    it { is_expected.to have_many(:persons) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:organization)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'organizations.json')
    end

    it 'invalid JSON does not create a valid Organization instance' do
      validate_invalid_json_to_model(clazz: Organization, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Organization instance' do
      obj = validate_minimal_json_to_model(clazz: Organization, jsons: @jsons)
      expect(obj.name).to eql(@json['name'])
      expect(obj.identifiers.first.value).to eql(@json['identifiers'].first['value'])
      expect(obj.identifiers.first.category).to eql('url')
    end

    it 'complete JSON creates a valid Organization instance' do
      obj = validate_complete_json_to_model(clazz: Organization, jsons: @jsons)
      expect(obj.name).to eql(@json['name'])
      expect(obj.identifiers.first.value).to eql(@json['identifiers'].first['value'])
      expect(obj.identifiers.first.category).to eql(@json['identifiers'].first['category'])
    end
  end
end
