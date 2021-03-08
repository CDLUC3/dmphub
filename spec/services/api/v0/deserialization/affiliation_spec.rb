# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Affiliation do
  before(:each) do
    @provenance = create(:provenance)
    @name = Faker::Company.name
    @abbrev = Faker::Lorem.word.upcase
    @affiliation = create(:affiliation, name: @name, alternate_names: [@abbrev])
    @category = 'ror'
    @value = SecureRandom.uuid
    @identifier = create(:identifier, identifiable: @affiliation, category: @category,
                                      value: @value, provenance: @provenance)
    @affiliation.reload
  end

  describe '#deserialize(provenance: provenance, json: {})' do
    before(:each) do
      @json = {
        name: @name,
        abbreviation: @abbrev,
        affiliation_id: {
          type: @category, identifier: @value
        }
      }
    end

    it 'returns nil if json is not valid' do
      expect(described_class.deserialize(provenance: @provenance, json: {})).to eql(nil)
    end
    it 'calls find_by_identifier' do
      allow(described_class).to receive(:find_by_identifier).and_return(@affiliation)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(described_class).to have_received(:find_by_identifier)
    end
    it 'calls find_by_name if find_by_identifier finds none' do
      allow(described_class).to receive(:find_by_identifier).and_return(nil)
      allow(described_class).to receive(:find_by_name).and_return(@affiliation)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(described_class).to have_received(:find_by_identifier)
      expect(described_class).to have_received(:find_by_name)
    end
    it 'attaches the identifier to the Affiliation' do
      allow(described_class).to receive(:find_by_identifier).and_return(@affiliation)
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.identifiers.length).to eql(1)
      expect(result.identifiers.first.category).to eql(@category)
      expect(result.identifiers.first.value).to eql(@value)
    end
    it 'updates the alternate_names for the Affiliation' do
      @json[:abbreviation] = Faker::Movies::StarWars.planet
      allow(described_class).to receive(:find_by_identifier).and_return(@affiliation)
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.alternate_names.length).to eql(2)
      expect(result.alternate_names.last).to eql(@json[:abbreviation])
    end
  end

  context 'private methods' do
    describe '#valid?(json:)' do
      it 'returns false if json is empty' do
        expect(described_class.send(:valid?, json: {})).to eql(false)
      end
      it 'returns false if :name is not present and identifier is not present' do
        json = { abbreviation: @abbrev }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it 'returns true if name is present' do
        json = { name: @name }
        expect(described_class.send(:valid?, json: json)).to eql(true)
      end
      it 'returns true if funder_id is present' do
        json = { funder_id: { type: @category, identifier: @value } }
        expect(described_class.send(:valid?, json: json)).to eql(true)
      end
      it 'returns true if affiliation_id is present' do
        json = { affiliation_id: { type: @category, identifier: @value } }
        expect(described_class.send(:valid?, json: json)).to eql(true)
      end
    end

    describe '#find_by_identifier(provenance: provenance, json:)' do
      it 'returns nil if :affiliation_id and :funder_id are not present' do
        json = { name: @name }
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: json)
        expect(result).to eql(nil)
      end
      it 'finds the Affiliation by :affiliation_id' do
        allow(Api::V0::Deserialization::Identifier).to receive(:deserialize).and_return(@identifier)
        json = { affiliation_id: { type: @category, identifier: @value } }
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: json)
        expect(result).to eql(@affiliation)
      end
      it 'finds the Affiliation by :funder_id' do
        allow(Api::V0::Deserialization::Identifier).to receive(:deserialize).and_return(@identifier)
        json = { funder_id: { type: @category, identifier: @value } }
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: json)
        expect(result).to eql(@affiliation)
      end
      it 'returns nil if no Affiliation was found' do
        json = { affiliation_id: { type: @category, provenance: @provenance, identifier: SecureRandom.uuid } }
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: json)
        expect(result).to eql(nil)
      end
    end

    describe '#find_by_name(provenance: provenance, json:)' do
      it 'returns nil if json is not present' do
        result = described_class.send(:find_by_name, provenance: @provenance, json: {})
        expect(result).to eql(nil)
      end
      it 'returns nil if :name is not present' do
        json = { abbreviation: @abbrev }
        result = described_class.send(:find_by_name, provenance: @provenance, json: json)
        expect(result).to eql(nil)
      end
      it 'finds the matching Affiliation by name' do
        json = { name: @affiliation.name }
        result = described_class.send(:find_by_name, provenance: @provenance, json: json)
        expect(result).to eql(@affiliation)
      end
      it 'finds the Affiliation from the ExternalApis::RorService' do
        json = { name: @affiliation.name }
        allow(ExternalApis::RorService).to receive(:search).and_return(@affiliation)
        result = described_class.send(:find_by_name, provenance: @provenance, json: json)
        expect(result).to eql(@affiliation)
      end
      it 'initializes the Affiliation if there were no viable matches' do
        json = {
          name: Faker::Movies::StarWars.planet,
          abbreviation: Faker::Lorem.unique.word.upcase,
          affiliation_id: {
            type: @category, identifier: SecureRandom.uuid
          }
        }
        allow(ExternalApis::RorService).to receive(:search).and_return(nil)
        result = described_class.send(:find_by_name, provenance: @provenance, json: json)
        expect(result.new_record?).to eql(true)
        expect(result.name).to eql(json[:name])
        expect(result.types).to eql([])
        expect(result.attrs).to eql({})
      end
    end

    describe '#attach_identifier(provenance: provenance, affiliation:, json:)' do
      it 'returns the Affiliation as-is if json is not present' do
        result = described_class.send(:attach_identifiers, provenance: @provenance,
                                                           affiliation: @affiliation, json: {})
        expect(result.identifiers).to eql(@affiliation.identifiers)
      end
      it 'returns the Affiliation as-is if the json has no identifier' do
        json = { name: @name }
        result = described_class.send(:attach_identifiers, provenance: @provenance,
                                                           affiliation: @affiliation, json: json)
        expect(result.identifiers).to eql(@affiliation.identifiers)
      end
      it 'returns the Affiliation as-is if the Affiliation is not a new record' do
        json = { affiliation_id: { type: @category, identifier: @identifier.value } }
        result = described_class.send(:attach_identifiers, provenance: @provenance,
                                                           affiliation: @affiliation, json: json)
        expect(result.identifiers).to eql(@affiliation.identifiers)
      end
      it 'initializes the identifier and adds it to the Affiliation for a :affiliation_id' do
        ::Identifier.all.destroy_all
        affiliation = build(:affiliation)
        category = ::Identifier.categories.keys.reject { |cat| cat == @category }.sample
        json = { affiliation_id: { type: category, identifier: @identifier.value } }
        count = affiliation.identifiers.length
        result = described_class.send(:attach_identifiers, provenance: @provenance,
                                                           affiliation: affiliation, json: json)
        expect(result.identifiers.length > count).to eql(true)
        expect(result.identifiers.last.category).to eql(category)
        id = result.identifiers.last.value
        expect(id).to eql(@identifier.value)
      end
      it 'initializes the identifier and adds it to the Affiliation for a :funder_id' do
        ::Identifier.all.destroy_all
        affiliation = build(:affiliation)
        category = ::Identifier.categories.keys.reject { |cat| cat == @category }.sample
        json = { funder_id: { type: category, identifier: @identifier.value } }
        count = affiliation.identifiers.length
        result = described_class.send(:attach_identifiers, provenance: @provenance,
                                                           affiliation: affiliation, json: json)
        expect(result.identifiers.length > count).to eql(true)
        expect(result.identifiers.last.category).to eql(category)
        id = result.identifiers.last.value
        expect(id).to eql(@identifier.value)
      end
    end
  end

  context 'Updates' do
    before(:each) do
      allow(ExternalApis::RorService).to receive(:search).and_return([])
      @json = {
        name: Faker::Company.unique.name,
        abbreviation: Faker::Lorem.word.upcase,
        affiliation_id: {
          type: ::Identifier.categories.keys.reject { |c| c == @affiliation.identifiers.first.category }.sample,
          identifier: Faker::Internet.url
        }
      }
    end

    it 'does not update the fields if no match is found in DB' do
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.new_record?).to eql(true)
    end
    it 'updates the record if matched by :identifier' do
      @json[:affiliation_id] = {
        type: @affiliation.identifiers.first.category,
        identifier: @affiliation.identifiers.first.value
      }
      affil = described_class.deserialize(provenance: @provenance, json: @json)
      # Expect the name and identifier not to have changed!
      expect(affil.name).to eql(@affiliation.name)
      expect(affil.identifiers.last).to eql(@affiliation.identifiers.last)
      expect(affil.alternate_names.include?(@json[:abbreviation])).to eql(true)
    end
    it 'updates the record if matched by :name' do
      @json[:name] = @affiliation.name
      affil = described_class.deserialize(provenance: @provenance, json: @json)
      # Expect the name and identifier not to have changed!
      expect(affil.name).to eql(@affiliation.name)
      expect(affil.identifiers.last).to eql(@affiliation.identifiers.last)
      expect(affil.alternate_names.include?(@json[:abbreviation])).to eql(true)
    end
  end
end
