# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identifier, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:provenance) }
    it { is_expected.to define_enum_for(:category).with(Identifier.categories.keys) }

    it 'should validate that :value is unique per :category+:provenance' do
      create(:identifier, category: Identifier.categories.keys.sample, identifiable: create(:person))
      subject.value = 'Duplicate'
      is_expected.to validate_uniqueness_of(:value).scoped_to(:category, :provenance)
                                                   .case_insensitive.with_message('has already been taken')
    end
  end

  context 'associations' do
    it { is_expected.to belong_to(:identifiable) }
  end

  it 'factory can produce a valid model' do
    model = create(:award_identifier)
    expect(model.valid?).to eql(true), 'expected Award to be Identifiable'
    model = create(:data_management_plan_identifier)
    expect(model.valid?).to eql(true), 'expected DataManagementPlan to be Identifiable'
    model = create(:dataset_identifier)
    expect(model.valid?).to eql(true), 'expected Dataset to be Identifiable'
    model = create(:person_identifier)
    expect(model.valid?).to eql(true), 'expected Person to be Identifiable'
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'identifiers.json')
    end

    it 'invalid JSON does not create a valid Identifier instance' do
      validate_invalid_json_to_model(clazz: Identifier, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Identifier instance' do
      obj = validate_minimal_json_to_model(clazz: Identifier, jsons: @jsons)
      expect(obj.category).to eql(@json['category'])
      expect(obj.value).to eql(@json['value'])
      expect(obj.provenance).to eql('Testing')
    end

    it 'complete JSON creates a valid Identifier instance' do
      obj = validate_complete_json_to_model(clazz: Identifier, jsons: @jsons)
      expect(obj.category).to eql(@json['category'])
      expect(obj.value).to eql(@json['value'])
      expect(obj.provenance).to eql('Testing')
    end
  end
end
