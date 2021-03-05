# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Funding do
  before(:each) do
    @provenance = create(:provenance)
    @funder = create(:affiliation, name: Faker::Company.name)
    @funding = create(:funding, affiliation: @funder)
    @funder_id = create(:identifier, identifiable: @funder, category: 'ror',
                                     value: SecureRandom.uuid)
    @grant_id = create(:identifier, identifiable: @funding, category: 'url',
                                    value: Faker::Internet.url)
    @funder.reload
    @funding.reload
    @project = build(:project)

    @json = {
      name: @funder.name,
      funder_id: {
        type: @funder_id.category, identifier: @funder_id.value
      },
      grant_id: {
        type: @grant_id.category, identifier: @grant_id.value
      },
      funding_status: %w[planned granted rejected].sample,
      dmproadmap_funding_opportunity_id: {
        type: ::Identifier.categories.keys.sample,
        identifier: SecureRandom.uuid
      },
      dmproadmap_funded_affiliations: [
        name: Faker::Company.unique.name
      ]
    }
  end

  describe '#deserialize(provenance:, project:, json: {})' do
    it 'returns nil if :provenance is not present' do
      result = described_class.deserialize(provenance: nil, project: @project, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if :project is not present' do
      result = described_class.deserialize(provenance: @provenance, project: nil, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json is not valid' do
      json = { funding_status: 'planned' }
      result = described_class.deserialize(provenance: @provenance, project: @project, json: json)
      expect(result).to eql(nil)
    end
    it 'returns nil if the funder can not be deserialized' do
      allow(Api::V0::Deserialization::Affiliation).to receive(:deserialize).and_return(nil)
      result = described_class.deserialize(provenance: @provenance, project: @project, json: @json)
      expect(result).to eql(nil)
    end
    it 'calls :find_funding' do
      allow(Api::V0::Deserialization::Affiliation).to receive(:deserialize).and_return(@funder)
      allow(described_class).to receive(:find_funding).and_return(@funding)
      described_class.deserialize(provenance: @provenance, project: @project, json: @json)
      expect(described_class).to have_received(:find_funding)
    end
  end

  context 'private methods' do
    describe '#valid?(json:)' do
      it 'returns false if json is not present' do
        expect(described_class.send(:valid?, json: {})).to eql(false)
      end
      it 'returns false if :name or :funder_id are not present' do
        json = { funding_status: %w[] }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it 'returns true if :name is present' do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
      it 'returns true if :funder_id is present' do
        json = {
          funder_id: { type: Faker::Lorem.word, identifier: SecureRandom.uuid }
        }
        expect(described_class.send(:valid?, json: json)).to eql(true)
      end
    end

    describe '#find_funding(provenance:, project:, affiliation:, json:)' do
      it 'returns nil unless json is present' do
        result = described_class.send(:find_funding, provenance: @provenance, project: @project,
                                                     affiliation: @affiliation, json: {})
        expect(result).to eql(nil)
      end
      it 'returns an existing Funding record' do
        @funding.status = 'rejected'
        @funding.provenance = nil
        allow(::Funding).to receive(:find_or_initialize_by).and_return(@funding)
        result = described_class.send(:find_funding, provenance: @provenance, project: @project,
                                                     affiliation: @funder, json: @json)
        expect(result).to eql(@funding)
        expect(result.status).to eql(@json[:funding_status])
        expect(result.provenance).to eql(@provenance)
      end
      it 'initializes a Funding record' do
        funding = build(:funding, project: @project, affiliation: @affiliation,
                                  status: nil)
        allow(::Funding).to receive(:find_or_initialize_by).and_return(funding)
        result = described_class.send(:find_funding, provenance: @provenance, project: @project,
                                                     affiliation: @funder, json: @json)
        expect(result).to eql(funding)
        expect(result.status).to eql(@json[:funding_status])
        expect(result.provenance).to eql(@provenance)
      end
      it 'calls :deserialize_grant' do
        allow(::Funding).to receive(:find_or_initialize_by).and_return(@funding)
        allow(described_class).to receive(:deserialize_grant).and_return(@grant_id)
        described_class.send(:find_funding, provenance: @provenance, project: @project,
                                            affiliation: @funder, json: @json)
        expect(described_class).to have_received(:deserialize_grant)
      end
    end

    describe '#deserialize_grant(provenance:, funding:, json:)' do
      it 'returns the Funding as-is if no json is present' do
        @grant_id.destroy
        result = described_class.send(:deserialize_grant, provenance: @provenance,
                                                          funding: @funding,
                                                          json: {})
        expect(result.urls.empty?).to eql(true)
      end
      it 'returns the Funding as-is if the identifier could not be deserialized' do
        @grant_id.destroy
        allow(Api::V0::Deserialization::Identifier).to receive(:deserialize).and_return(nil)
        result = described_class.send(:deserialize_grant, provenance: @provenance,
                                                          funding: @funding, json: @json)
        expect(result.urls.empty?).to eql(true)
      end
      it 'attaches the the grant to the funding' do
        @grant_id.identifiable = nil
        @funding.reload
        allow(Api::V0::Deserialization::Identifier).to receive(:deserialize).and_return(@grant_id)
        result = described_class.send(:deserialize_grant, provenance: @provenance,
                                                          funding: @funding, json: @json)
        expect(result.urls.length).to eql(1)
        expect(result.urls.first.category).to eql(@json[:grant_id][:type])
        expect(result.urls.first.value).to eql(@json[:grant_id][:identifier])
      end
    end

    describe '#attach_funding_opportunity_id(provenance:, funding:, json:)' do
      before(:each) do
        @id_count = @funding.identifiers.length
      end
      it "returns :funding as-is if json is not present" do
        result = described_class.send(:attach_funding_opportunity_id, provenance: @provenance,
                                                                      funding: @funding, json: nil)
        expect(result).to eql(@funding)
        expect(result.identifiers.length).to eql(@id_count)
      end
      it "returns :funding as-is if json[:dmproadmap_funding_opportunity_id] is not present" do
        @json[:dmproadmap_funding_opportunity_id] = {}
        result = described_class.send(:attach_funding_opportunity_id, provenance: @provenance,
                                                                      funding: @funding, json: @json)
        expect(result).to eql(@funding)
        expect(result.identifiers.length).to eql(@id_count)
      end
      it "returns :funding as-is if the json[:dmproadmap_funding_opportunity_id] is invalid" do
        @json[:dmproadmap_funding_opportunity_id] = { identifier: SecureRandom.uuid }
        result = described_class.send(:attach_funding_opportunity_id, provenance: @provenance,
                                                                      funding: @funding, json: @json)
        expect(result).to eql(@funding)
        expect(result.identifiers.length).to eql(@id_count)
      end
      it "attaches the json[:dmproadmap_funding_opportunity_id] to :funding" do
        result = described_class.send(:attach_funding_opportunity_id, provenance: @provenance,
                                                                      funding: @funding, json: @json)
        expect(result).to eql(@funding)
        expect(result.identifiers.length).to eql(@id_count + 1)
        expected = @json[:dmproadmap_funding_opportunity_id][:identifier]
        expect(result.identifiers.map(&:value).include?(expected)).to eql(true)
      end
    end

    describe '#deserialize_funded_affiliations(provenance:, funding:, json:)' do
      before(:each) do
        @affil_count = @funding.funded_affiliations.length
      end
      it "returns :funding as-is if json is not present" do
        result = described_class.send(:deserialize_funded_affiliations, provenance: @provenance,
                                                                        funding: @funding, json: nil)
        expect(result).to eql(@funding)
        expect(result.funded_affiliations.length).to eql(@affil_count)
      end
      it "returns :funding as-is if json[:dmproadmap_funded_affiliations] is not present" do
        @json.delete(:dmproadmap_funded_affiliations)
        result = described_class.send(:deserialize_funded_affiliations, provenance: @provenance,
                                                                        funding: @funding, json: @json)
        expect(result).to eql(@funding)
        expect(result.funded_affiliations.length).to eql(@affil_count)
      end
      it "returns :funding as-is if json[:dmproadmap_funded_affiliations] is empty" do
        @json[:dmproadmap_funded_affiliations] = []
        result = described_class.send(:deserialize_funded_affiliations, provenance: @provenance,
                                                                        funding: @funding, json: @json)
        expect(result).to eql(@funding)
        expect(result.funded_affiliations.length).to eql(@affil_count)
      end
      it "returns :funding as-is if the json[:dmproadmap_funded_affiliations] is invalid" do
        @json[:dmproadmap_funded_affiliations] = [{ foo: "bar" }]
        result = described_class.send(:deserialize_funded_affiliations, provenance: @provenance,
                                                                        funding: @funding, json: @json)
        expect(result).to eql(@funding)
        expect(result.funded_affiliations.length).to eql(@affil_count)
      end
      it "attaches the json[:dmproadmap_funded_affiliations] to :funding" do
        allow(Api::V0::Deserialization::Affiliation).to receive(:deserialize).and_return(build(:affiliation))
        result = described_class.send(:deserialize_funded_affiliations, provenance: @provenance,
                                                                        funding: @funding, json: @json)
        expect(result).to eql(@funding)
        expect(result.funded_affiliations.length).to eql(@affil_count + 1)
      end
    end
  end

  context "Updates" do
    before(:each) do
      allow(ExternalApis::RorService).to receive(:search).and_return([])
      @json = {
        name: Faker::Movies::StarWars.unique.character,
        funder_id: {
          type: ::Identifier.categories.keys.sample,
          identifier: Faker::Internet.unique.url
        },
        grant_id: {
          type: ::Identifier.categories.keys.sample,
          identifier: Faker::Internet.unique.url
        },
        funding_status: %w[planned granted rejected].sample,
        dmproadmap_funding_opportunity_id: {
          type: ::Identifier.categories.keys.sample,
          identifier: Faker::Internet.unique.url
        },
        dmproadmap_funded_affiliations: [{ name: Faker::Company.name }]
      }
    end
    it 'does not update the fields if no match is found in DB' do
      result = described_class.deserialize(provenance: @provenance, project: @project, json: @json)
      expect(result.new_record?).to eql(true)
    end
    it 'updates the record if matched by :project && :affiliation' do
      @json[:funder_id] = { type: @funder_id.category, identifier: @funder_id.value }
      fund = described_class.deserialize(provenance: @provenance, project: @project, json: @json)
      ids = fund.identifiers.map(&:value)
      expect(fund.new_record?).to eql(false)
      expect(fund.affiliation).to eql(@funder)
      expect(fund.status).to eql(@json[:funding_status])
      expect(ids.include?(@json[:grant_id][:identifier])).to eql(true)
      expect(ids.include?(@json[:dmproadmap_funding_opportunity_id][:identifier])).to eql(true)
    end
  end
end
