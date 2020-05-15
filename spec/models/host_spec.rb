# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Host, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:distribution) }
    it { is_expected.to have_many(:identifiers) }
  end

  it 'factory can produce a valid model' do
    model = create(:host)
    expect(model.valid?).to eql(true)
  end

  describe 'errors' do
    before :each do
      @model = build(:host)
    end
    it 'includes identifier errors' do
      @model.identifiers << build(:identifier, category: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Category can\'t be blank')).to eql(true)
    end
  end

  describe 'cascading deletes' do
    it 'does not delete the distribution' do
      distribution = create(:distribution)
      model = create(:host, distribution: distribution)
      model.destroy
      expect(Distribution.last).to eql(distribution)
    end
    it 'deletes associated identifiers' do
      model = create(:host, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end

  describe 'from_json!' do
    before(:each) do
      @distribution = create(:distribution)
      @jsons = open_json_mock(file_name: 'hosts.json')
    end

    it 'invalid JSON does not create a valid Host instance' do
      validate_invalid_json_to_model(clazz: Host, jsons: @jsons, distribution: @distribution)
    end

    it 'minimal JSON creates a valid Host instance' do
      obj = validate_minimal_json_to_model(clazz: Host, jsons: @jsons, distribution: @distribution)
      expect(obj.title).to eql(@json['title'])
    end

    it 'complete JSON creates a valid Host instance' do
      obj = validate_complete_json_to_model(clazz: Host, jsons: @jsons, distribution: @distribution)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(ConversionService.boolean_to_yes_no_unknown(obj.supports_versioning)).to eql(@json['supportsVersioning'])
      expect(obj.backup_type).to eql(@json['backupType'])
      expect(obj.backup_frequency).to eql(@json['backupFrequency'])
      expect(obj.storage_type).to eql(@json['storageType'])
      expect(obj.availability).to eql(@json['availability'])
      expect(obj.geo_location).to eql(@json['geoLocation'])
      expect(obj.identifiers.first.value).to eql(@json['hostIds'].first['value'])
    end

    it 'returns the existing record if the identifier already exists' do
      host = create(:host, :complete, distribution: @distribution)
      ident = host.identifiers.first
      json = hash_to_json(hash: {
                            title: Faker::Lorem.sentence,
                            host_ids: [{
                              category: ident.category,
                              value: ident.value
                            }]
                          })
      obj = Host.from_json!(provenance: ident.provenance, json: json, distribution: @distribution)
      expect(obj.new_record?).to eql(false)
      expect(obj.id).to eql(host.id)
      expect(obj.identifiers.length).to eql(host.identifiers.length)
    end

    it 'createsa a new record' do
      obj = Host.from_json!(
        provenance: Faker::Lorem.word,
        distribution: @distribution,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
    end
  end
end
