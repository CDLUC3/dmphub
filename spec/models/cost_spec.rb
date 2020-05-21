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

  describe 'cascading deletes' do
    it 'does not delete the data_management_plan' do
      dmp = create(:data_management_plan, project: create(:project))
      model = create(:cost, data_management_plan: dmp)
      model.destroy
      expect(DataManagementPlan.last).to eql(dmp)
    end
  end

  describe 'from_json' do
    before(:each) do
      @dmp = build(:data_management_plan)
      @jsons = open_json_mock(file_name: 'costs.json')
    end

    it 'invalid JSON does not create a valid Cost instance' do
      validate_invalid_json_to_model(clazz: Cost, jsons: @jsons, data_management_plan: @dmp)
    end

    it 'minimal JSON creates a valid Cost instance' do
      obj = validate_minimal_json_to_model(clazz: Cost, jsons: @jsons, data_management_plan: @dmp)
      expect(obj.title).to eql(@json['title'])
    end

    it 'complete JSON creates a valid Cost instance' do
      obj = validate_complete_json_to_model(clazz: Cost, jsons: @jsons, data_management_plan: @dmp)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.value).to eql(@json['value'])
      expect(obj.currency_code).to eql(@json['currency_code'])
    end

    it 'finds the existing record rather than creating a new instance' do
      cost = create(:cost, data_management_plan: @dmp, title: @jsons['minimal']['title'])
      obj = Cost.from_json!(
        provenance: Faker::Lorem.word,
        data_management_plan: @dmp,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(cost.id).to eql(obj.id)
    end

    it 'createsa a new record' do
      obj = Cost.from_json!(
        provenance: Faker::Lorem.word,
        data_management_plan: @dmp,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
    end
  end
end
