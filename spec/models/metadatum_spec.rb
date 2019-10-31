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

  describe 'cascading deletes' do
    it 'does not delete the dataset' do
      dataset = create(:dataset)
      model = create(:metadatum, :complete, dataset: dataset)
      model.destroy
      expect(Dataset.last).to eql(dataset)
    end
    it 'deletes associated identifiers' do
      model = create(:metadatum, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end

  describe 'from_json!' do
    before(:each) do
      @dataset = build(:dataset)
      @jsons = open_json_mock(file_name: 'metadata.json')
    end

    it 'invalid JSON does not create a valid Metadatum instance' do
      validate_invalid_json_to_model(clazz: Metadatum, jsons: @jsons, dataset: @dataset)
    end

    it 'minimal JSON creates a valid Metadatum instance' do
      obj = validate_minimal_json_to_model(clazz: Metadatum, jsons: @jsons, dataset: @dataset)
      expect(obj.language).to eql(@json['language'])
      expect(obj.identifiers.first.value).to eql(@json['identifier']['value'])
    end

    it 'complete JSON creates a valid Metadatum instance' do
      obj = validate_complete_json_to_model(clazz: Metadatum, jsons: @jsons, dataset: @dataset)
      expect(obj.language).to eql(@json['language'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.identifiers.first.value).to eql(@json['identifier']['value'])
    end

    it 'returns the existing record if the identifier already exists' do
      metadatum = create(:metadatum, :complete)
      ident = metadatum.identifiers.first
      json = hash_to_json(hash: {
        description: Faker::Lorem.paragraph,
        language: %w[en fr es de].sample,
        identifier: {
          category: ident.category,
          value: ident.value
        }
      })
      obj = Metadatum.from_json!(provenance: ident.provenance, json: json, dataset: @dataset)
      expect(obj.new_record?).to eql(false)
      expect(obj.id).to eql(metadatum.id)
      expect(obj.identifiers.length).to eql(metadatum.identifiers.length)
    end

    it 'createsa a new record' do
      obj = Metadatum.from_json!(
        provenance: Faker::Lorem.word,
        dataset: @dataset,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
    end
  end
end
