# frozen_string_literal: true

require 'rails_helper'

RSpec.describe License, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:license_uri) }
    it { is_expected.to validate_presence_of(:start_date) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:distribution) }
  end

  it 'factory can produce a valid model' do
    model = create(:license)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the distribution' do
      distro = create(:distribution)
      model = create(:license, distribution: distro)
      model.destroy
      expect(Distribution.last).to eql(distro)
    end
  end

  describe 'from_json' do
    before(:each) do
      @distribution = build(:distribution)
      @jsons = open_json_mock(file_name: 'licenses.json')
    end

    it 'invalid JSON does not create a valid License instance' do
      validate_invalid_json_to_model(clazz: License, jsons: @jsons, distribution: @distribution)
    end

    it 'minimal JSON creates a valid License instance' do
      obj = validate_minimal_json_to_model(clazz: License, jsons: @jsons, distribution: @distribution)
      expect(obj.license_uri).to eql(@json['licenseRef'])
      expect(obj.start_date.to_s).to eql(@json['startDate'])
    end

    it 'complete JSON creates a valid License instance' do
      obj = validate_complete_json_to_model(clazz: License, jsons: @jsons, distribution: @distribution)
      expect(obj.license_uri).to eql(@json['licenseRef'])
      expect(obj.start_date.to_s).to eql(@json['startDate'])
    end

    it 'finds the existing record rather than creating a new instance' do
      license = create(:license, distribution: @distribution, license_uri: @jsons['minimal']['licenseRef'])
      obj = License.from_json!(
        provenance: Faker::Lorem.word,
        distribution: @distribution,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(license.id).to eql(obj.id)
    end

    it 'createsa a new record' do
      obj = License.from_json!(
        provenance: Faker::Lorem.word,
        distribution: @distribution,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
    end
  end
end
