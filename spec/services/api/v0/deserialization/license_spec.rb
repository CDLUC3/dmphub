# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::License do
  before(:each) do
    @distribution = build(:distribution)
    @provenance = create(:provenance)
    @license = create(:license, provenance: @provenance, distribution: @distribution)

    @json = {
      license_ref: Faker::Internet.unique.url,
      start_date: Time.now.utc.to_formatted_s(:iso8601)
    }
  end

  describe '#deserialize(provenance:, distribution:, json: {})' do
    it 'returns nil if :provenance is not present' do
      result = described_class.deserialize(provenance: nil, distribution: @distribution, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if :dmp is not present' do
      result = described_class.deserialize(provenance: @provenance, distribution: nil, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:license_ref] is not present' do
      @json.delete(:license_ref)
      result = described_class.deserialize(provenance: @provenance, distribution: @distribution, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:start_date] is not present' do
      @json.delete(:start_date)
      result = described_class.deserialize(provenance: @provenance, distribution: @distribution, json: @json)
      expect(result).to eql(nil)
    end
    it 'updates an existing License for the same :start_date' do
      @json[:start_date] = @license.start_date.to_formatted_s(:iso8601)
      result = described_class.deserialize(provenance: @provenance, distribution: @distribution, json: @json)
      expect(result.new_record?).to eql(false)
      expect(result.license_ref).to eql(@json[:license_ref])
      expect(result.start_date).to eql(@license.start_date)
    end
    it 'initializes a new License for a unique :license_ref and :start_date' do
      result = described_class.deserialize(provenance: @provenance, distribution: @distribution, json: @json)
      expect(result.new_record?).to eql(true)
      expect(result.license_ref).to eql(@json[:license_ref])
      expect(result.start_date.to_formatted_s(:iso8601)).to eql(@json[:start_date])
    end
    it 'initializes a new License for duplicate :license_ref with a different :start_date' do
      @json[:license_ref] = @license.license_ref
      result = described_class.deserialize(provenance: @provenance, distribution: @distribution, json: @json)
      expect(result.new_record?).to eql(true)
      expect(result.license_ref).to eql(@json[:license_ref])
      expect(result.start_date.to_formatted_s(:iso8601)).to eql(@json[:start_date])
    end
  end
end
