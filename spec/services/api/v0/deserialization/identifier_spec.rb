# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Identifier do
  before(:each) do
    @uniquers = Identifier.send(:requires_universal_uniqueness)
    @nonuniquers = Identifier.categories.keys.reject { |cat| @uniquers.include?(cat) }
    @provenance = Faker::Lorem.unique.word.downcase
    @value = SecureRandom.uuid
    @identifiable = build(:affiliation)
  end

  describe '#valid?(json:)' do
    it 'returns nil if json is not valid' do
      expect(described_class.send(:valid?, json: nil)).to eql(false)
    end
    it 'returns nil if :identifier is not present' do
      json = { type: @uniquers.sample }
      expect(described_class.send(:valid?, json: json)).to eql(false)
    end
    it 'returns nil if :type is not present' do
      json = { identifier: @value }
      expect(described_class.send(:valid?, json: json)).to eql(false)
    end
    it 'returns true' do
      json = { type: @uniquers.sample, identifier: @value }
      expect(described_class.send(:valid?, json: json)).to eql(true)
    end
  end

  describe '#deserialize(identifiable:, json:)' do
    it 'returns nil if json is not valid' do
      result = described_class.deserialize(identifiable: @identifiable,
                                           provenance: @provenance, json: nil)
      expect(result).to eql(nil)
    end
    it 'returns nil if :type is not a valid category' do
      json = { type: 'foo', identifier: @value }
      result = described_class.deserialize(identifiable: @identifiable,
                                           provenance: @provenance, json: json)
      expect(result).to eql(nil)
    end
    context 'category that must be universally unique (e.g. DOI, URL)' do
      before(:each) do
        @json = { type: @uniquers.sample, identifier: @value }
      end
      it 'returns the existing identifier' do
        id = create(:identifier, identifiable: @identifiable, provenance: @provenance,
                                 category: @json[:type], value: @value)
        result = described_class.deserialize(identifiable: @identifiable,
                                             provenance: @provenance, json: @json)
        expect(result).to eql(id)
        validate_identifier(result: result, provenance: @provenance,
                            category: @json[:type], value: @value)
      end
      it 'initializes a new identifier' do
        result = described_class.deserialize(identifiable: @identifiable,
                                             provenance: @provenance, json: @json)
        expect(result.new_record?).to eql(true)
        validate_identifier(result: result, provenance: @provenance,
                            category: @json[:type], value: @value)
      end
    end

    context 'category that does NOT need to be universally unique (e.g. program)' do
      before(:each) do
        @json = { type: @nonuniquers.sample, identifier: @value }
      end
      it 'returns the existing identifier' do
        id = create(:identifier, identifiable: @identifiable, provenance: @provenance,
                                 category: @json[:type], value: @value)
        result = described_class.deserialize(identifiable: @identifiable,
                                             provenance: @provenance, json: @json)
        expect(result).to eql(id)
        validate_identifier(result: result, provenance: @provenance,
                            category: @json[:type], value: @value)
      end
      it 'initializes a new identifier' do
        result = described_class.deserialize(identifiable: @identifiable,
                                             provenance: @provenance, json: @json)
        expect(result.new_record?).to eql(true)
        validate_identifier(result: result, provenance: @provenance,
                            category: @json[:type], value: @value)
      end
    end
  end

  describe '#find_existing(provenance:, identifiable:, json:)' do
    it 'returns nil if json is not present' do
      result = described_class.send(:find_existing, provenance: @provenance,
                                                    identifiable: @identifiable,
                                                    json: nil)
      expect(result).to eql(nil)
    end
    it 'returns nil if :type is not present' do
      result = described_class.send(:find_existing, provenance: @provenance,
                                                    identifiable: @identifiable,
                                                    json: { identifier: @value })
      expect(result).to eql(nil)
    end
    it 'returns nil if :type is not a valid category' do
      json = { type: 'foo', identifier: @value }
      result = described_class.send(:find_existing, provenance: @provenance,
                                                    identifiable: @identifiable,
                                                    json: json)
      expect(result).to eql(nil)
    end
    context 'category that must be universally unique (e.g. DOI, URL)' do
      before(:each) do
        @json = { type: @uniquers.sample, identifier: @value }
      end
      it 'returns nil if the specified identifiable does not match the one found' do
        create(:identifier, identifiable: create(:affiliation), provenance: @provenance,
                            category: @json[:type], value: @value)
        result = described_class.send(:find_existing, provenance: @provenance,
                                                      identifiable: @identifiable,
                                                      json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the identifier if no identifiable is specified' do
        id = create(:identifier, identifiable: create(:affiliation), provenance: @provenance,
                                 category: @json[:type], value: @value)
        result = described_class.send(:find_existing, provenance: @provenance,
                                                      identifiable: nil,
                                                      json: @json)
        expect(result).to eql(id)
        validate_identifier(result: result, provenance: @provenance,
                            category: @json[:type], value: @value)
      end
      it 'returns the identifier' do
        id = create(:identifier, identifiable: @identifiable, provenance: 'foo',
                                 category: @json[:type], value: @value)
        result = described_class.send(:find_existing, provenance: @provenance,
                                                      identifiable: @identifiable,
                                                      json: @json)
        expect(result).to eql(id)
        validate_identifier(result: result, provenance: @provenance,
                            category: @json[:type], value: @value)
      end
    end

    context 'category that does NOT need to be universally unique (e.g. program)' do
      before(:each) do
        @json = { type: @nonuniquers.sample, identifier: @value }
      end
      it 'returns nil if the :provenance does not match' do
        create(:identifier, identifiable: @identifiable, provenance: 'foo',
                            category: @json[:type], value: @value)
        result = described_class.send(:find_existing, provenance: @provenance,
                                                      identifiable: @identifiable,
                                                      json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the identifier if no identifiable is specified' do
        id = create(:identifier, identifiable: @identifiable, provenance: @provenance,
                                 category: @json[:type], value: @value)
        result = described_class.send(:find_existing, provenance: @provenance,
                                                      identifiable: nil,
                                                      json: @json)
        expect(result).to eql(id)
        expect(result.provenance).to eql(@provenance)
        validate_identifier(result: result, provenance: @provenance,
                            category: @json[:type], value: @value)
      end
      it 'returns the identifier' do
        id = create(:identifier, identifiable: @identifiable, provenance: @provenance,
                                 category: @json[:type], value: @value)
        result = described_class.send(:find_existing, provenance: @provenance,
                                                      identifiable: @identifiable,
                                                      json: @json)
        expect(result).to eql(id)
        expect(result.provenance).to eql(@provenance)
        validate_identifier(result: result, provenance: @provenance,
                            category: @json[:type], value: @value)
      end
    end
  end

  private

  def validate_identifier(result:, provenance:, category:, value:)
    expect(result.is_a?(Identifier)).to eql(true), 'expected it to be an Identifier'
    expect(result.category.to_s).to eql(category.to_s), 'expected categories to match'
    expect(result.value).to eql(value), 'expected values to match'
  end
end
