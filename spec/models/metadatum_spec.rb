# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metadatum, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:language) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
  end

  it 'factory can produce a valid model' do
    model = create(:metadatum)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'metadata.json')
    end

    it 'invalid JSON does not create a valid Metadatum instance' do
      validate_invalid_json_to_model(clazz: Metadatum, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Metadatum instance' do
      obj = validate_minimal_json_to_model(clazz: Metadatum, jsons: @jsons)
      expect(obj.language).to eql(@json['language'])
      expect(obj.identifiers.first.value).to eql(@json['identifier']['value'])
    end

    it 'complete JSON creates a valid Metadatum instance' do
      obj = validate_complete_json_to_model(clazz: Metadatum, jsons: @jsons)
      expect(obj.language).to eql(@json['language'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.identifiers.first.value).to eql(@json['identifier']['value'])
    end
  end
end
