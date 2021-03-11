# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Identifier do
  before(:each) do
    @uniquers = Identifier.send(:requires_universal_uniqueness).map(&:to_s)
    @nonuniquers = Identifier.categories.keys.reject { |cat| @uniquers.include?(cat) }
    @provenance = create(:provenance)
    @value = SecureRandom.uuid
    @identifiable = create(:affiliation, provenance: @provenance)
    @identifier = create(:identifier, identifiable: @identifiable, provenance: @provenance)
    @doi = create(:identifier, identifiable: @identifiable, category: 'doi', provenance: @provenance)
    @json = {
      type: ::Identifier.categories.keys.sample,
      identifier: SecureRandom.uuid
    }
  end

  describe '#deserialize(provenance:, identifiable:, identifiable_type: nil, json: {}, descriptor: \'is_identified_by\')' do
    it 'returns nil if not valid' do
      result = described_class.deserialize(provenance: @provenance, identifiable: nil,
                                           identifiable_type: 'Affiliation')
      expect(result).to eql(nil)
    end
    it 'finds the identifier when :identifiable_type is not specified by :identifiable is' do
      json = { type: @identifier.category, identifier: @identifier.value }
      result = described_class.deserialize(provenance: @provenance, identifiable: @identifiable, json: json)
      expect(result).to eql(@identifier)
    end
    it 'finds the Identifier when :identifiable_type is specified but :identifiable is not' do
      json = { type: @doi.category, identifier: @doi.value }
      result = described_class.deserialize(provenance: @provenance, identifiable: nil,
                                           identifiable_type: 'Affiliation', json: json)
      expect(result).to eql(@doi)
    end
    it 'initializes a new Identifier when :identifiable is nil' do
      result = described_class.deserialize(provenance: @provenance, identifiable: nil, json: @json,
                                           identifiable_type: 'Affiliation')
      expect(result.new_record?).to eql(true)
      expect(result.identifiable_type).to eql(nil)
      expect(result.category).to eql(@json[:type])
      expect(result.value).to eql(@json[:identifier])
      expect(result.descriptor).to eql('is_identified_by')
    end
    it 'initializes a new Identifier when :identifiable is not nil' do
      result = described_class.deserialize(provenance: @provenance, identifiable: @identifiable, json: @json)
      expect(result.new_record?).to eql(true)
      expect(result.identifiable_type).to eql('Affiliation')
      expect(result.category).to eql(@json[:type])
      expect(result.value).to eql(@json[:identifier])
      expect(result.descriptor).to eql('is_identified_by')
    end
    it 'uses the specified descriptor' do
      result = described_class.deserialize(provenance: @provenance, identifiable: @identifiable, json: @json,
                                           descriptor: 'is_referenced_by')
      expect(result.new_record?).to eql(true)
      expect(result.descriptor).to eql('is_referenced_by')
    end
  end

  context 'private methods' do
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

    describe '#type_to_category(json: {})' do
      it 'returns nil unless json is present' do
        expect(described_class.send(:type_to_category, json: nil)).to eql(nil)
      end
      it 'uses the specified :type if its a valid :category' do
        typ = ::Identifier.categories.keys.sample
        result = described_class.send(:type_to_category, json: { type: typ, identifier: Faker::Internet.url })
        expect(result).to eql(typ)
      end
      it 'derives the :category from the :identifier value' do
        typ = 'foo'
        result = described_class.send(:type_to_category, json: { type: typ, identifier: Faker::Internet.url })
        expect(result).to eql('url')
      end
    end

    describe '#find_existing(provenance:, identifiable:, json:)' do
      it 'returns nil if json is not present' do
        result = described_class.send(:find_existing, identifiable: @identifiable, json: nil)
        expect(result).to eql(nil)
      end
      context 'category that must be universally unique (e.g. DOI, URL)' do
        before(:each) do
          @url = create(:identifier, category: 'url', value: Faker::Internet.url,
                                     descriptor: 'is_identified_by', identifiable: @identifiable)
          @json = { type: 'url', identifier: Faker::Internet.url }
        end
        it 'finds the Identifier if :identifiable is not specified but :identiable_type is' do
          json = { type: @url.category, identifier: @url.value }
          result = described_class.send(:find_existing, identifiable: nil,
                                                        identifiable_type: 'Affiliation',
                                                        json: json)
          expect(result).to eql(@url)
        end
        it 'finds the Identifier if :identifiable is specified but :identiable_type is not' do
          json = { type: @url.category, identifier: @url.value }
          result = described_class.send(:find_existing, identifiable: @identifiable,
                                                        json: json)
          expect(result).to eql(@url)
        end
        it 'does not find the Identifier if :identifiable does not match' do
          create(:identifier, identifiable: create(:host), provenance: @provenance,
                              category: @json[:type], value: @json[:identifier])
          result = described_class.send(:find_existing, identifiable: @identifiable,
                                                        json: @json)
          expect(result).to eql(nil)
        end
        it 'does not find the Identifier if :identifiable_type does not match' do
          create(:identifier, identifiable: create(:host), provenance: @provenance,
                              category: @json[:type], value: @json[:identifier])
          result = described_class.send(:find_existing, identifiable: nil,
                                                        identifiable_type: 'Affiliation',
                                                        json: @json)
          expect(result).to eql(nil)
        end
        it 'does not find the Identifier when values do not match' do
          create(:identifier, identifiable: create(:host), provenance: @provenance,
                              category: @json[:type], value: @value)
          result = described_class.send(:find_existing, identifiable: nil,
                                                        identifiable_type: 'Host',
                                                        json: @json)
          expect(result).to eql(nil)
        end
      end

      context 'category that does NOT need to be universally unique (e.g. program, other, etc.)' do
        before(:each) do
          @other = create(:identifier, category: 'other', value: SecureRandom.uuid,
                                       descriptor: 'is_identified_by', identifiable: @identifiable)
          @json = { type: 'other', identifier: SecureRandom.uuid }
        end
        it 'does not find the Identifier if :identifiable is not specified' do
          json = { type: @other.category, identifier: @other.value }
          result = described_class.send(:find_existing, identifiable: nil,
                                                        identifiable_type: 'Affiliation',
                                                        json: json)
          expect(result).to eql(nil)
        end
        it 'finds the Identifier if :identifiable is specified' do
          json = { type: @other.category, identifier: @other.value }
          result = described_class.send(:find_existing, identifiable: @identifiable,
                                                        json: json)
          expect(result).to eql(@other)
        end
        it 'does not find the Identifier if :identifiable does not match' do
          create(:identifier, identifiable: create(:host), provenance: @provenance,
                              category: @json[:type], value: @json[:identifier])
          result = described_class.send(:find_existing, identifiable: @identifiable,
                                                        json: @json)
          expect(result).to eql(nil)
        end
        it 'does not find the Identifier if :identifiable_type does not match' do
          create(:identifier, identifiable: create(:host), provenance: @provenance,
                              category: @json[:type], value: @json[:identifier])
          result = described_class.send(:find_existing, identifiable: nil,
                                                        identifiable_type: 'Affiliation',
                                                        json: @json)
          expect(result).to eql(nil)
        end
        it 'does not find the Identifier when values do not match' do
          create(:identifier, identifiable: create(:host), provenance: @provenance,
                              category: @json[:type], value: SecureRandom.uuid)
          result = described_class.send(:find_existing, identifiable: nil,
                                                        identifiable_type: 'Host',
                                                        json: @json)
          expect(result).to eql(nil)
        end
      end
    end
  end
end
