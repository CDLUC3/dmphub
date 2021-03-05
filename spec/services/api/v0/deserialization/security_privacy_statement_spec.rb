# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::SecurityPrivacyStatement do
  before(:each) do
    @dataset = create(:dataset)
    @provenance = create(:provenance)
    @statement = create(:security_privacy_statement, provenance: @provenance, dataset: @dataset)

    @json = {
      title: Faker::Lorem.sentence,
      description: [Faker::Lorem.paragraph, Faker::Lorem.word]
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
    it 'updates an existing SecurityPrivacyStatement' do
      @json[:title] = @statement.title
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(result.new_record?).to eql(false)
      expect(result.title).to eql(@statement.title)
      expect(result.description).to eql(@json[:description].join('<br>'))
    end
    it 'initializes a new SecurityPrivacyStatement' do
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(result.new_record?).to eql(true)
      expect(result.title).to eql(@json[:title])
      expect(result.description).to eql(@json[:description].join('<br>'))
    end
  end
end
