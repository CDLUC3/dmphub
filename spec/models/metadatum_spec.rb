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

    it 'returns the existing record if the identifier already exists' do
      metadatum = create(:metadatum, :complete)
      ident = metadatum.identifiers.first
      obj = Metadatum.from_json(provenance: ident.provenance,
                                json: hash_to_json(hash: {
                                                     description: Faker::Lorem.paragraph,
                                                     language: %w[en fr es de].sample,
                                                     identifier: {
                                                       category: ident.category,
                                                       value: ident.value
                                                     }
                                                   }))
      expect(obj.new_record?).to eql(false)
      expect(obj.id).to eql(metadatum.id)
      expect(obj.identifiers.length).to eql(metadatum.identifiers.length)
    end

    it 'finds the existing record rather than creating a new instance' do
      metadatum = create(:metadatum, dataset: create(:dataset), description: @jsons['minimal']['description'],
                                     language: @jsons['minimal']['language'])
      obj = Metadatum.from_json(
        provenance: Faker::Lorem.word,
        dataset: metadatum.dataset,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(metadatum.id).to eql(obj.id)
    end
  end
end
