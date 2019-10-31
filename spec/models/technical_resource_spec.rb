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

  it 'errors includes identifier errors' do
    model = build(:technical_resource)
    model.identifiers << build(:identifier, category: nil)
    model.validate
    expect(model.errors.full_messages.include?('Category can\'t be blank')).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the dataset' do
      dataset = create(:dataset)
      model = create(:technical_resource, :complete, dataset: dataset)
      model.destroy
      expect(Dataset.last).to eql(dataset)
    end
    it 'deletes associated identifiers' do
      model = create(:technical_resource, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end

  describe 'from_json!' do
    before(:each) do
      @dataset = build(:dataset)
      @jsons = open_json_mock(file_name: 'technical_resources.json')
    end

    it 'invalid JSON does not create a valid TechnicalResource instance' do
      validate_invalid_json_to_model(clazz: TechnicalResource, jsons: @jsons, dataset: @dataset)
    end

    it 'minimal JSON creates a valid TechnicalResource instance' do
      obj = validate_minimal_json_to_model(clazz: TechnicalResource, jsons: @jsons, dataset: @dataset)
      expect(obj.identifiers.first.value).to eql(@json['identifier']['value'])
      expect(obj.identifiers.first.category).to eql('url')
    end

    it 'complete JSON creates a valid TechnicalResource instance' do
      obj = validate_complete_json_to_model(clazz: TechnicalResource, jsons: @jsons, dataset: @dataset)
      expect(obj.description).to eql(@json['description'])
      expect(obj.identifiers.first.value).to eql(@json['identifier']['value'])
      expect(obj.identifiers.first.category).to eql(@json['identifier']['category'])
    end

    it 'returns the existing record if the identifier already exists' do
      technical_resource = create(:technical_resource, :complete)
      ident = technical_resource.identifiers.first
      json = hash_to_json(hash: {
        description: Faker::Lorem.paragraph,
        identifier: {
          category: ident.category,
          value: ident.value
        }
      })
      obj = TechnicalResource.from_json!(provenance: ident.provenance,
                                         json: json, dataset: @dataset)
      expect(obj.new_record?).to eql(false)
      expect(obj.id).to eql(technical_resource.id)
      expect(obj.identifiers.length).to eql(technical_resource.identifiers.length)
    end

    it 'creates a new record' do
      obj = TechnicalResource.from_json!(
        provenance: Faker::Lorem.word,
        dataset: @dataset,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(TechnicalResource.last).to eql(obj)
    end
  end
end
