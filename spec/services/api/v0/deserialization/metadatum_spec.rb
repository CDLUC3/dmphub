# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Metadatum do
  before(:each) do
    @provenance = create(:provenance)
    @dataset = create(:dataset)
    @metadatum = create(:metadatum, provenance: @provenance, dataset: @dataset)
    @category = ::Identifier.requires_universal_uniqueness.sample.to_s
    @value = SecureRandom.uuid
    @identifier = create(:identifier, identifiable: @metadatum, category: @category,
                                      value: @value, provenance: @provenance)
    @metadatum.reload

    @json = {
      description: Faker::Lorem.paragraph,
      language: Api::V0::ConversionService::LANGUAGES.sample,
      metadata_standard_id: {
        type: ::Identifier.categories.keys.reject { |k| k == @category }.sample,
        identifier: Faker::Internet.url
      }
    }
  end

  describe '#deserialize(provenance: provenance, dataset:, json: {})' do
    it 'returns nil if json is not valid' do
      expect(described_class.deserialize(provenance: @provenance, dataset: @dataset, json: {})).to eql(nil)
    end
    it 'calls find_by_identifier' do
      allow(described_class).to receive(:find_by_identifier).and_return(@metadatum)
      described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(described_class).to have_received(:find_by_identifier)
    end
    it 'attaches the identifier to the Metadatum' do
      allow(described_class).to receive(:find_by_identifier).and_return(create(:metadatum))
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(result.identifiers.length).to eql(1)
      expect(result.identifiers.first.category).to eql(@json[:metadata_standard_id][:type])
      expect(result.identifiers.first.value).to eql(@json[:metadata_standard_id][:identifier])
    end
    it 'updates the description and language for the Metadatum' do
      allow(described_class).to receive(:find_by_identifier).and_return(@metadatum)
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(result.description).to eql(@json[:description])
      expect(result.language).to eql(@json[:language])
    end
  end

  context 'private methods' do
    describe '#valid?(json:)' do
      it 'returns false if json is empty' do
        expect(described_class.send(:valid?, json: {})).to eql(false)
      end
      it 'returns false if :metadata_standard_id is not present' do
        @json.delete(:metadata_standard_id)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns false if metadata_standard_id[:identifier] is not present' do
        @json[:metadata_standard_id].delete(:identifier)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns true if :metadata_standard_id is present' do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
    end

    describe '#find_by_identifier(provenance: provenance, json:)' do
      it 'returns nil if :metadata_standard_id are not present' do
        @json.delete(:metadata_standard_id)
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: @json)
        expect(result).to eql(nil)
      end
      it 'finds the Metadatum by :metadata_standard_id' do
        @json[:metadata_standard_id][:type] = @category
        @json[:metadata_standard_id][:identifier] = @value
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: @json)
        expect(result).to eql(@metadatum)
      end
      it 'returns a new Metadatum if none was found' do
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: @json)
        expect(result.new_record?).to eql(true)
      end
    end

    describe '#attach_identifier(provenance: provenance, metadatum:, json:)' do
      it 'returns the Metadatum as-is if json is not present' do
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          metadatum: @metadatum, json: {})
        expect(result.identifiers).to eql(@metadatum.identifiers)
      end
      it 'returns the Metadatum as-is if the json has no identifier' do
        @json.delete(:metadata_standard_id)
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          metadatum: @metadatum, json: @json)
        expect(result.identifiers).to eql(@metadatum.identifiers)
      end
      it 'does not replace the identifier for an existing Metadatum' do
        @json[:metadata_standard_id] = { type: @category, identifier: @identifier.value }
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          metadatum: @metadatum, json: @json)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.last).to eql(@identifier)
        expect(result.identifiers.last.new_record?).to eql(false)
      end
      it 'initializes the identifier and adds it to the Metadatum for a :metadata_standard_id' do
        @metadatum.destroy
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          metadatum: @metadatum, json: @json)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.last).not_to eql(@identifier)
        expect(result.identifiers.last.new_record?).to eql(false)
        expect(result.identifiers.last.category).to eql(@json[:metadata_standard_id][:type])
        expect(result.identifiers.last.value).to eql(@json[:metadata_standard_id][:identifier])
      end
    end
  end

  context 'Updates' do
    it 'does not update the fields if no match is found in DB' do
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      expect(result.new_record?).to eql(true)
    end
    it 'updates the record if matched by :metadata_standard_id' do
      @json[:metadata_standard_id] = { type: @category, identifier: @value }
      result = described_class.deserialize(provenance: @provenance, dataset: @dataset, json: @json)
      # Expect the name and identifier not to have changed!
      expect(result.description).to eql(@json[:description])
      expect(result.language).to eql(@json[:language])
      expect(result.identifiers.last).to eql(@metadatum.identifiers.last)
    end
  end
end
