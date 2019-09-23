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
    model = create(:identifier, identifiable: create(:award))
    expect(model.valid?).to eql(true), 'expected Award to be Identifiable'
    model = create(:identifier, identifiable: create(:data_management_plan))
    expect(model.valid?).to eql(true), 'expected DataManagementPlan to be Identifiable'
    model = create(:identifier, identifiable: create(:dataset))
    expect(model.valid?).to eql(true), 'expected Dataset to be Identifiable'
    model = create(:identifier, identifiable: create(:host))
    expect(model.valid?).to eql(true), 'expected Host to be Identifiable'
    model = create(:identifier, identifiable: create(:metadatum))
    expect(model.valid?).to eql(true), 'expected Metadatum to be Identifiable'
    model = create(:identifier, identifiable: create(:organization))
    expect(model.valid?).to eql(true), 'expected Organization to be Identifiable'
    model = create(:identifier, identifiable: create(:person))
    expect(model.valid?).to eql(true), 'expected Person to be Identifiable'
    model = create(:identifier, identifiable: create(:technical_resource))
    expect(model.valid?).to eql(true), 'expected TechnicalResource to be Identifiable'
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

    it 'returns the existing record if it already exists' do
      identifier = create(:identifier, identifiable: create(:person))
      obj = Identifier.from_json(
        provenance: identifier.provenance,
        json: { category:  identifier.category, value: identifier.value }
      )
      expect(obj.new_record?).to eql(false)
      expect(obj.id).to eql(identifier.id)
    end

  end
end
