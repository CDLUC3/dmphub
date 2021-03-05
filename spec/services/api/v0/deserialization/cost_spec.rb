# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Cost do
  before(:each) do
    @dmp = build(:data_management_plan)
    @provenance = create(:provenance)
    @cost = create(:cost, provenance: @provenance, data_management_plan: @dmp)

    @json = {
      currency_code: Api::V0::ConversionService::CURRENCY_CODES.sample,
      title: Faker::Lorem.sentence,
      description: Faker::Lorem.paragraph,
      value: Faker::Number.number
    }
  end

  describe '#deserialize(provenance:, dmp:, json: {})' do
    it 'returns nil if :provenance is not present' do
      result = described_class.deserialize(provenance: nil, dmp: @dmp, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if :dmp is not present' do
      result = described_class.deserialize(provenance: @provenance, dmp: nil, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:title] is not present' do
      @json.delete(:title)
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:currency_code] is not present' do
      @json.delete(:currency_code)
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:value] is not present' do
      @json.delete(:value)
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result).to eql(nil)
    end
    it 'updates an existing Cost' do
      @json[:title] = @cost.title
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result.new_record?).to eql(false)
      expect(result.title).to eql(@cost.title)
      expect(result.description).to eql(@json[:description])
      expect(result.currency_code).to eql(Api::V0::ConversionService.currency_code(code: @json[:currency_code]))
      expect(result.value).to eql(@json[:value].to_f)
    end
    it 'initializes a new Cost' do
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result.new_record?).to eql(true)
      expect(result.title).to eql(@json[:title])
      expect(result.description).to eql(@json[:description])
      expect(result.currency_code).to eql(Api::V0::ConversionService.currency_code(code: @json[:currency_code]))
      expect(result.value).to eql(@json[:value].to_f)
    end
  end
end
