# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cost, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:data_management_plan) }
  end

  it 'factory can produce a valid model' do
    model = create(:cost)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'costs.json')
    end

    it 'invalid JSON does not create a valid Cost instance' do
      validate_invalid_json_to_model(clazz: Cost, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Cost instance' do
      obj = validate_minimal_json_to_model(clazz: Cost, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
    end

    it 'complete JSON creates a valid Cost instance' do
      obj = validate_complete_json_to_model(clazz: Cost, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.value).to eql(@json['value'])
      expect(obj.currency_code).to eql(@json['currency_code'])
    end
  end
end
