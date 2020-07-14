# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::Deserialization::Project do
  before(:each) do
    @dmp = build(:data_management_plan)
    @provenance = create(:provenance)
    @project = create(:project, provenance: @provenance, title: Faker::Lorem.sentence)
    @dmp.project = @project

    @json = {
      title: @project.title,
      description: @project.description,
      start: @project.start_on.to_formatted_s(:iso8601),
      end: @project.end_on.to_formatted_s(:iso8601)
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
    it 'returns nil if json is not valid' do
      json = { funding_status: 'planned' }
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: json)
      expect(result).to eql(nil)
    end
    it 'returns nil if the dmp can not be deserialized' do
      @json.delete(:title)
      result = described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(result).to eql(nil)
    end
    it 'calls :find_by_dmp_and_title' do
      allow(described_class).to receive(:find_by_dmp_and_title).and_return(@project)
      described_class.deserialize(provenance: @provenance, dmp: @dmp, json: @json)
      expect(described_class).to have_received(:find_by_dmp_and_title)
    end
    it 'sets the values' do
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
