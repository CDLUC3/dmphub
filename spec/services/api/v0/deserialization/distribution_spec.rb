# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Distribution do
  before(:each) do
    @provenance = create(:provenance)
    @dataset = create(:dataset, provenance: @provenance)
    @host = create(:host)
    create(:identifier, identifiable: @host, category: 'url', value: Faker::Internet.url,
                        descriptor: 'is_identified_by')
    @host.reload
    @distribution = create(:distribution, provenance: @provenance, dataset: @dataset, host: @host)

    @json = {
      title: Faker::Movies::StarWars.planet,
      access_url: Faker::Internet.unique.url,
      available_until: (Time.now + 2.years).utc.to_formatted_s(:iso8601),
      byte_size: Faker::Number.number,
      data_access: Distribution.data_accesses.keys.sample,
      description: Faker::Lorem.paragraph,
      download_url: Faker::Internet.unique.url,
      format: Faker::Lorem.word,
      host: { title: Faker::Music::PearlJam.song, url: Faker::Internet.unique.url },
      license: [
        { license_ref: Faker::Internet.unique.url, start_date: Time.now.utc.to_formatted_s(:iso8601) }
      ]
    }
  end

  describe '#deserialize(provenance:, dataset:, json: {})' do
    it 'returns nil if :provenance is not present' do
      result = described_class.deserialize(provenance: nil, dataset: @dataset, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if :dataset is not present' do
      result = described_class.deserialize(provenance: @provenance, dataset: nil, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:title] is not present' do
      @json.delete(:title)
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:data_access] is not present' do
      @json.delete(:data_access)
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(result).to eql(nil)
    end
    it 'initializes a new Distribution' do
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(result.new_record?).to eql(true)
    end
  end

  context 'private methods' do
    describe '#valid?(json:)' do
      it 'returns false if json is empty' do
        expect(described_class.send(:valid?, json: {})).to eql(false)
      end
      it 'returns false if :title is not present and :data_acces is not present' do
        json = { description: Faker::Lorem.paragraph }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it 'returns false if :title is not present' do
        json = { data_access: Distribution.data_accesses.keys.sample }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it 'returns false if :data_acces is not present' do
        json = { title: Faker::Lorem.word }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it 'returns true if :title and :data_acces present' do
        json = { title: Faker::Lorem.word, data_access: Distribution.data_accesses.keys.sample }
        expect(described_class.send(:valid?, json: json)).to eql(true)
      end
    end

    describe '#deserialize_licenses(provenance:, distribution:, json:)' do
      it 'returns the Distribution as-is if no :licenses are specified' do
        @json.delete(:license)
        result = described_class.send(:deserialize_licenses, provenance: @provenance,
                                                             distribution: @distribution, json: @json)
        expect(result.licenses).to eql(@distribution.licenses)
      end
      it 'returns the Distribution if the license is not new' do
        license = create(:license)
        @json[:license] = [{
          license_ref: license.license_ref,
          start_date: license.start_date.to_formatted_s(:iso8601)
        }]
        result = described_class.send(:deserialize_licenses, provenance: @provenance,
                                                             distribution: @distribution, json: @json)
        expect(result.licenses.last.new_record?).to eql(false)
      end
      it 'adds the license to the :licenses association' do
        result = described_class.send(:deserialize_licenses, provenance: @provenance,
                                                             distribution: build(:distribution), json: @json)
        expect(result.licenses.last.new_record?).to eql(true)
      end
    end
  end

  context 'Updates' do
    it 'does not update the fields if no match is found in DB' do
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(result.new_record?).to eql(true)
    end
    it 'updates the record if matched by :title and :host' do
      @json[:title] = @distribution.title
      @json[:host] = { title: @host.title, url: @host.identifiers.last.value }
      result = verify_expected_updates
      expect(result.access_url).to eql(@json[:access_url])
      expect(result.download_url).to eql(@json[:download_url])

      # Expect that it did not update the :download_url, :title or :host
      expect(result.title).to eql(@distribution.title)
      expect(result.host.title).to eql(@distribution.host.title)
      expect(result.host.identifiers.last.value).to eql(@distribution.host.identifiers.last.value)
    end
    it 'updates the :host if matched and NO :host previously defined' do
      @json[:title] = @distribution.title
      @json[:access_url] = @distribution.access_url
      result = verify_expected_updates
      expect(result.host.title).to eql(@json[:host][:title])
      expect(result.host.identifiers.last.value).to eql(@json[:host][:url])
    end
  end

  # rubocop:disable Metrics/AbcSize
  def verify_expected_updates
    result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
    expect(result.available_until.to_formatted_s(:iso8601)).to eql(@json[:available_until])
    expect(result.byte_size).to eql(@json[:byte_size].to_f)
    expect(result.data_access).to eql(@json[:data_access])
    expect(result.description).to eql(@json[:description])
    expect(result.format).to eql(@json[:format])
    expect(result.licenses.last.license_ref).to eql(@json[:license].first[:license_ref])
    expect(result.licenses.last.start_date.to_formatted_s(:iso8601)).to eql(@json[:license].first[:start_date])
    result
  end
  # rubocop:enable Metrics/AbcSize
end
