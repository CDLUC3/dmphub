# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dataset, type: :model do

  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:dataset_type) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:data_management_plan) }
    it { is_expected.to have_many(:keywords) }
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:security_privacy_statements) }
    it { is_expected.to have_many(:technical_resources) }
    it { is_expected.to have_many(:metadata) }
    it { is_expected.to have_many(:distributions) }
  end

  it 'factory can produce a valid model' do
    model = create(:dataset)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'datasets.json')
    end

    it 'invalid JSON does not create a valid Dataset instance' do
      validate_invalid_json_to_model(clazz: Dataset, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Dataset instance' do
      obj = validate_minimal_json_to_model(clazz: Dataset, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
    end

    it 'complete JSON creates a valid Dataset instance' do
      obj = validate_complete_json_to_model(clazz: Dataset, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.dataset_type).to eql(@json['type'])
      expect(obj.publication_date.to_s).to eql(@json['issued'])
      expect(obj.language).to eql(@json['language'])
      expect(ConversionService.boolean_to_yes_no_unknown(obj.personal_data)).to eql(@json['personal_data'])
      expect(ConversionService.boolean_to_yes_no_unknown(obj.sensitive_data)).to eql(@json['sensitive_data'])
      expect(obj.data_quality_assurance).to eql(@json['data_quality_assurance'])
      expect(obj.preservation_statement).to eql(@json['preservation_statement'])
      expect(obj.identifiers.first.value).to eql(@json['identifiers'].first['value'])
      expect(obj.security_privacy_statements.first.title).to eql(@json['security_and_privacy_statements'].first['title'])
      expect(obj.technical_resources.first.description).to eql(@json['technical_resources'].first['description'])
      expect(obj.metadata.first.description).to eql(@json['metadata'].first['description'])
      expect(obj.keywords.length).to eql(@json['keywords'].length)
      expect(obj.keywords.first.value).to eql(@json['keywords'].first)
      expect(obj.distributions.first.title).to eql(@json['distributions'].first['title'])
    end
  end

end
