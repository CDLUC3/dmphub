# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Host do
  before(:each) do
    @provenance = create(:provenance)
    @host = create(:host, provenance: @provenance)
    @identifier = create(:identifier, identifiable: @host,
                                      category: Identifier.requires_universal_uniqueness.sample.to_s,
                                      value: SecureRandom.uuid, provenance: @provenance)
    @url = create(:identifier, identifiable: @host, category: 'url',
                               value: Faker::Internet.url, provenance: @provenance)
    @host.reload

    @json = {
      title: Faker::Movies::StarWars.planet,
      availability: Faker::Lorem.word,
      backup_frequency: Faker::Lorem.word,
      backup_type: Faker::Lorem.word,
      certified_with: Api::V0::ConversionService::CERTIFICATIONS.sample,
      description: Faker::Lorem.paragraph,
      geo_location: Api::V0::ConversionService::GEO_LOCATIONS.sample,
      pid_system: Api::V0::ConversionService::PID_SYSTEMS.sample,
      storage_type: Faker::Lorem.sentence,
      support_versioning: %w[yes no unknown].sample,
      url: Faker::Internet.url,
      dmproadmap_host_id: { type: Identifier.categories.keys.sample, identifier: SecureRandom.uuid }
    }
  end

  describe '#deserialize(provenance:, json: {})' do
    it 'returns nil if :provenance is not present' do
      result = described_class.deserialize(provenance: nil, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:title] is not present' do
      @json.delete(:title)
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json[:url] is not present' do
      @json.delete(:url)
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result).to eql(nil)
    end
    it 'finds an existing Host by its :dmproadmap_host_id' do
      @json[:dmproadmap_host_id] = { type: @identifier.category, identifier: @identifier.value }
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.new_record?).to eql(false)
    end
    it 'finds an existing Host by its :title' do
      @json[:title] = @host.title
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.new_record?).to eql(false)
    end
    it 'finds an existing Host by its :url' do
      @json[:url] = @url.value
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.new_record?).to eql(false)
    end
    it 'initializes a new Host' do
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.new_record?).to eql(true)
    end
  end

  context 'private methods' do
    describe '#valid?(json:)' do
      it 'returns false if json is empty' do
        expect(described_class.send(:valid?, json: {})).to eql(false)
      end
      it 'returns false if :title is not present and :url is not present' do
        json = { description: Faker::Lorem.paragraph }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it 'returns false if :title is not present' do
        json = { url: Faker::Internet.url }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it 'returns false if :url is not present' do
        json = { title: Faker::Lorem.word }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it 'returns true if :title and :url present' do
        json = { title: Faker::Lorem.word, url: Faker::Internet.url }
        expect(described_class.send(:valid?, json: json)).to eql(true)
      end
    end

    describe '#find_by_identifier(provenance: provenance, json:)' do
      it 'returns nil if :dmproadmap_host_id is not present' do
        json = { name: @name }
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: json)
        expect(result).to eql(nil)
      end
      it 'finds the Host by :dmproadmap_host_id' do
        allow(Api::V0::Deserialization::Identifier).to receive(:deserialize).and_return(@identifier)
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: @json)
        expect(result).to eql(@host)
      end
      it 'finds the Host by :url' do
        allow(Api::V0::Deserialization::Identifier).to receive(:deserialize).and_return(nil)
        allow(Identifier).to receive(:where).and_return([@identifier])
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: @json)
        expect(result).to eql(@host)
      end
      it 'returns nil if no Host was found' do
        allow(Api::V0::Deserialization::Identifier).to receive(:deserialize).and_return(nil)
        allow(Identifier).to receive(:where).and_return([])
        result = described_class.send(:find_by_identifier, provenance: @provenance, json: @json)
        expect(result).to eql(nil)
      end
    end

    describe '#attach_identifier(provenance: provenance, host:, json:)' do
      it 'returns the Host as-is if json is not present' do
        result = described_class.send(:attach_identifier, provenance: @provenance, host: @host, json: {})
        expect(result.identifiers).to eql(@host.identifiers)
      end
      it 'returns the Host as-is if the json has no dmproadmap_host_id[:identifier]' do
        @json.delete(:dmproadmap_host_id)
        result = described_class.send(:attach_identifier, provenance: @provenance, host: @host, json: @json)
        expect(result.identifiers).to eql(@host.identifiers)
      end
      it 'returns the Host as-is if the Host is not a new record' do
        @json[:dmproadmap_host_id] = { type: @identifier.category, identifier: @identifier.value }
        result = described_class.send(:attach_identifier, provenance: @provenance, host: @host, json: @json)
        expect(result.identifiers).to eql(@host.identifiers)
      end
      it 'initializes the identifier and adds it to the Host for a new :dmproadmap_host_id' do
        result = described_class.send(:attach_identifier, provenance: @provenance,
                                                          host: build(:host), json: @json)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.last.category).to eql(@json[:dmproadmap_host_id][:type])
        expect(result.identifiers.last.value).to eql(@json[:dmproadmap_host_id][:identifier])
      end
    end

    describe '#attach_host_landing_page(provenance: provenance, host:, url:)' do
      it 'returns the Host as-is if url is not present' do
        result = described_class.send(:attach_host_landing_page, provenance: @provenance, host: @host, url: nil)
        expect(result.identifiers).to eql(@host.identifiers)
      end
      it 'returns the Host as-is if the Host is not a new record' do
        result = described_class.send(:attach_host_landing_page, provenance: @provenance,
                                                                 host: @host, url: Faker::Internet.url)
        expect(result.identifiers).to eql(@host.identifiers)
      end
      it 'initializes the identifier and adds it to the Host for a new :dmproadmap_host_id' do
        url = Faker::Internet.url
        result = described_class.send(:attach_host_landing_page, provenance: @provenance,
                                                                 host: build(:host), url: url)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.last.category).to eql('url')
        expect(result.identifiers.last.value).to eql(url)
        expect(result.identifiers.last.descriptor).to eql('is_identified_by')
      end
    end
  end

  context 'Updates' do
    it 'does not update the fields if no match is found in DB' do
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.new_record?).to eql(true)
    end
    it 'updates the record if matched by :url' do
      @json[:url] = @url.value
      result = described_class.deserialize(provenance: @provenance, json: @json)
      # Expect the name and identifier not to have changed!
      expect(result.description).to eql(@json[:description])
      expect(result.availability).to eql(@json[:availability])
      expect(result.backup_frequency).to eql(@json[:backup_frequency])
      expect(result.backup_type).to eql(@json[:backup_type])
      expect(result.certified_with).to eql(@json[:certified_with])
      expect(result.geo_location).to eql(@json[:geo_location])
      expect(result.pid_system).to eql(@json[:pid_system])
      expect(result.storage_type).to eql(@json[:storage_type])
      expected = Api::V0::ConversionService.yes_no_unknown_to_boolean(@json[:support_versioning])
      expect(result.supports_versioning).to eql(expected)
      # Expect that it did not update the :url or :title
      expect(result.title).to eql(@host.title)
      expect(result.identifiers.map(&:value).include?(@json[:url])).to eql(true)
      expect(result.identifiers.map(&:value).include?(@identifier.value)).to eql(true)
    end
    it 'updates the record if matched by :dmproadmap_host_id' do
      @json[:dmproadmap_host_id] = { type: @identifier.category, identifier: @identifier.value }
      result = described_class.deserialize(provenance: @provenance, json: @json)
      # Expect the name and identifier not to have changed!
      expect(result.description).to eql(@json[:description])
      expect(result.availability).to eql(@json[:availability])
      expect(result.backup_frequency).to eql(@json[:backup_frequency])
      expect(result.backup_type).to eql(@json[:backup_type])
      expect(result.certified_with).to eql(@json[:certified_with])
      expect(result.geo_location).to eql(@json[:geo_location])
      expect(result.pid_system).to eql(@json[:pid_system])
      expect(result.storage_type).to eql(@json[:storage_type])
      expected = Api::V0::ConversionService.yes_no_unknown_to_boolean(@json[:support_versioning])
      expect(result.supports_versioning).to eql(expected)
      # Expect that it did not update the :dmproadmap_host_id or :title
      expect(result.title).to eql(@host.title)
      expect(result.identifiers.map(&:value).include?(@json[:dmproadmap_host_id][:identifier])).to eql(true)
      expect(result.identifiers.map(&:value).include?(@url.value)).to eql(true)
    end
    it 'updates the :dmproadmap_host_id if matched by :url and the :dmproadmap_host_id is missing' do
      @json[:url] = @url.value
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.identifiers.map(&:value).include?(@json[:dmproadmap_host_id][:identifier])).to eql(true)
    end
    it 'updates the :url if matched by :dmproadmap_host_id and the :url is missing' do
      @json[:dmproadmap_host_id] = { type: @identifier.category, identifier: @identifier.value }
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.identifiers.map(&:value).include?(@json[:url])).to eql(true)
    end
  end
end
