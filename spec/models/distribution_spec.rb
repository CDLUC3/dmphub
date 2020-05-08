# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Distribution, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to define_enum_for(:data_access).with(Distribution.data_accesses.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
    it { is_expected.to have_many(:licenses) }
    it { is_expected.to have_one(:host) }
  end

  it 'factory can produce a valid model' do
    model = create(:distribution)
    expect(model.valid?).to eql(true)
  end

  describe 'errors' do
    before :each do
      @model = build(:distribution)
    end
    it 'includes license errors' do
      @model.licenses << build(:license, license_uri: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('License uri can\'t be blank')).to eql(true)
    end
    it 'includes host errors' do
      @model.host = build(:host, title: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Title can\'t be blank')).to eql(true)
    end
  end

  describe 'cascading deletes' do
    it 'does not delete the dataset' do
      dataset = create(:dataset)
      model = create(:distribution, dataset: dataset)
      model.destroy
      expect(Dataset.last).to eql(dataset)
    end
    it 'deletes associated licenses' do
      license = create(:license)
      ident = license.id
      model = create(:distribution, licenses: [license])
      model.destroy
      expect(License.where(id: ident).empty?).to eql(true)
    end
    it 'deletes associated host' do
      host = create(:host)
      ident = host.id
      model = create(:distribution, host: host)
      model.destroy
      expect(Host.where(id: ident).empty?).to eql(true)
    end
  end

  describe 'from_json!' do
    before(:each) do
      @dataset = build(:dataset)
      @jsons = open_json_mock(file_name: 'distributions.json')
    end

    it 'invalid JSON does not create a valid Distribution instance' do
      validate_invalid_json_to_model(clazz: Distribution, jsons: @jsons, dataset: @dataset)
    end

    it 'minimal JSON creates a valid Distribution instance' do
      obj = validate_minimal_json_to_model(clazz: Distribution, jsons: @jsons, dataset: @dataset)
      expect(obj.title).to eql(@json['title'])
      expect(obj.data_access).to eql('closed')
    end

    it 'complete JSON creates a valid Distribution instance' do
      obj = validate_complete_json_to_model(clazz: Distribution, jsons: @jsons, dataset: @dataset)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.format).to eql(@json['format'])
      expect(obj.byte_size).to eql(@json['byteSize'])
      expect(obj.access_url).to eql(@json['accessUrl'])
      expect(obj.download_url).to eql(@json['downloadUrl'])
      expect(obj.data_access).to eql(@json['dataAccess'])
      expect(obj.available_until.to_s).to eql(@json['availableUntil'])
      expect(obj.licenses.first.license_uri).to eql(@json['licenses'].first['licenseRef'])
      expect(obj.host.title).to eql(@json['host']['title'])
    end

    it 'finds the existing record rather than creating a new instance' do
      distribution = create(:distribution, dataset: @dataset, title: @jsons['minimal']['title'])
      obj = Distribution.from_json!(
        provenance: Faker::Lorem.word,
        dataset: @dataset,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(distribution.id).to eql(obj.id)
    end

    it 'creates a new record' do
      obj = Distribution.from_json!(
        provenance: Faker::Lorem.word,
        dataset: @dataset,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
    end
  end
end
