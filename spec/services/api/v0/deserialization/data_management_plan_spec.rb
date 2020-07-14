# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::DataManagementPlan do
  before(:each) do
    @provenance = Faker::Lorem.word.downcase
    @dmp = create(:data_management_plan, :complete, provenance: @provenance)

    @json = {
      title: @dmp.title,
      description: @dmp.description,
      language: @dmp.language,
      ethical_issues_exist: Api::V0::ConversionService.boolean_to_yes_no_unknown(@dmp.ethical_issues),
      ethical_issues_report: @dmp.ethical_issues_report,
      ethical_issues_description: @dmp.ethical_issues_description,
      dmp_id: { type: Identifier.categories.keys.sample, identifier: SecureRandom.uuid },
      contact: { name: @dmp.primary_contact.name, mbox: @dmp.primary_contact.email }
    }
  end

  describe '#deserialize(provenance:, json: {})' do
    it 'returns nil if :provenance is not present' do
      result = described_class.deserialize(provenance: nil, json: @json)
      expect(result).to eql(nil)
    end
    it 'returns nil if json is not valid' do
      result = described_class.deserialize(provenance: @provenance, json: nil)
      expect(result).to eql(nil)
    end
    it 'returns nil if the dmp can not be deserialized' do
      @json.delete(:title)
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result).to eql(nil)
    end
    it 'calls :find_by_identifier' do
      allow(described_class).to receive(:find_by_identifier).and_return(@dmp)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(described_class).to have_received(:find_by_identifier)
    end
    it 'calls Api::V0::Contributor.deserialize' do
      allow(Api::V0::Deserialization::Contributor).to receive(:deserialize).and_return(@dmp.primary_contact)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(Api::V0::Deserialization::Contributor).to have_received(:deserialize)
    end
    it 'calls :find_by_contact_and_title' do
      allow(described_class).to receive(:find_by_contact_and_title).and_return(@dmp)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(described_class).to have_received(:find_by_contact_and_title)
    end
    it 'calls the :deserialze methods for the associations' do
      allow(described_class).to receive(:deserialize_projects).and_return(@dmp)
      allow(described_class).to receive(:deserialize_contributors).and_return(@dmp)
      allow(described_class).to receive(:deserialize_datasets).and_return(@dmp)
      described_class.deserialize(provenance: @provenance, json: @json)
      expect(described_class).to have_received(:deserialize_projects)
      expect(described_class).to have_received(:deserialize_contributors)
      expect(described_class).to have_received(:deserialize_datasets)
    end
    it 'sets the values' do
      allow(described_class).to receive(:find_by_identifier).and_return(@dmp)
      result = described_class.deserialize(provenance: @provenance, json: @json)
      expect(result.title).to eql(@json[:title])
      expect(result.description).to eql(@json[:description])
      expect(result.language).to eql(@json[:language])
      expect(Api::V0::ConversionService.boolean_to_yes_no_unknown(result.ethical_issues)).to eql(@json[:ethical_issues_exist])
      expect(result.ethical_issues_report).to eql(@json[:ethical_issues_report])
      expect(result.ethical_issues_description).to eql(@json[:ethical_issues_description])
      expect(result.primary_contact.email).to eql(@json[:contact][:mbox])
    end
  end

  context 'private methods' do
    describe '#valid?(json:)' do
      it 'returns false if json is not present' do
        expect(described_class.send(:valid?, json: {})).to eql(false)
      end
      it 'returns true if :title, dmp_id[:identifier] and contact[:mbox] are present' do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
      it 'returns false if :title is not present' do
        @json.delete(:title)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns false if contact[:mbox] is not present' do
        @json[:contact].delete(:mbox)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns false if dmp_id[:identifier] is not present' do
        @json[:dmp_id].delete(:identifier)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
    end

    describe '#find_by_dmp_and_title(provenance:, dmp:, json:)' do
      it 'returns an existing Project record' do
        result = described_class.send(:find_by_dmp_and_title, provenance: @provenance, dmp: @dmp, json: @json)
        expect(result).to eql(@project)
      end
      it 'initializes a Project record' do
        json = {
          title: Faker::Lorem.unique.word,
          start: Time.now.to_formatted_s(:iso8601),
          end: (Time.now + 2.years).to_formatted_s(:iso8601)
        }
        result = described_class.send(:find_by_dmp_and_title, provenance: @provenance, dmp: @dmp, json: json)
        expect(result.new_record?).to eql(true)
        expect(result.title).to eql(json[:title])
        expect(result.provenance).to eql(@provenance)
      end
    end
  end
end
