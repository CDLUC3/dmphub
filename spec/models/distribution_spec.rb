# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Distribution, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
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

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'distributions.json')
    end

    it 'invalid JSON does not create a valid Distribution instance' do
      validate_invalid_json_to_model(clazz: Distribution, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Distribution instance' do
      obj = validate_minimal_json_to_model(clazz: Distribution, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.data_access).to eql('closed')
    end

    it 'complete JSON creates a valid Distribution instance' do
      obj = validate_complete_json_to_model(clazz: Distribution, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.format).to eql(@json['format'])
      expect(obj.byte_size).to eql(@json['byte_size'])
      expect(obj.access_url).to eql(@json['access_url'])
      expect(obj.download_url).to eql(@json['download_url'])
      expect(obj.data_access).to eql(@json['data_access'])
      expect(obj.available_until.to_s).to eql(@json['available_until'])
      expect(obj.licenses.first.license_uri).to eql(@json['licenses'].first['license_ref'])
      expect(obj.host.title).to eql(@json['host']['title'])
    end
  end
end
