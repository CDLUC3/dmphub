# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TechnicalResource, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:technical_resource)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'technical_resources.json')
    end

    it 'invalid JSON does not create a valid TechnicalResource instance' do
      validate_invalid_json_to_model(clazz: TechnicalResource, jsons: @jsons)
    end

    it 'minimal JSON creates a valid TechnicalResource instance' do
      obj = validate_minimal_json_to_model(clazz: TechnicalResource, jsons: @jsons)
      expect(obj.identifiers.first.value).to eql(@json['identifier']['value'])
      expect(obj.identifiers.first.category).to eql('url')
    end

    it 'complete JSON creates a valid TechnicalResource instance' do
      obj = validate_complete_json_to_model(clazz: TechnicalResource, jsons: @jsons)
      expect(obj.description).to eql(@json['description'])
      expect(obj.identifiers.first.value).to eql(@json['identifier']['value'])
      expect(obj.identifiers.first.category).to eql(@json['identifier']['category'])
    end
  end
end
