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
      contact: { email: @dmp.primary_contact.email }
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
    xit 'calls :find_by_identifier' do
      allow(described_class).to receive(:find_by_dmp_and_title).and_return(@project)
      described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(described_class).to have_received(:find_by_dmp_and_title)
    end
    xit 'calls :find_by_contact_and_title' do

    end
    xit 'sets the values' do
      allow(described_class).to receive(:find_by_dmp_and_title).and_return(@project)
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result.description).to eql(@json[:description])
      expect(result.start_on&.to_formatted_s(:iso8601)).to eql(@json[:start])
      expect(result.end_on&.to_formatted_s(:iso8601)).to eql(@json[:end])
    end
  end

  context 'private methods' do
    describe '#valid?(json:)' do
      it 'returns false if json is not present' do
        expect(described_class.send(:valid?, json: {})).to eql(false)
      end
      it 'returns true if :title, :start and :end are present' do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
      it 'returns false if :title is not present' do
        @json.delete(:title)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns false if :start is not present' do
        @json.delete(:start)
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it 'returns false if :end is not present' do
        @json.delete(:end)
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
