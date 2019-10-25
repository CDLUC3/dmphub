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
      expect(obj.identifiers.first.value).to eql(@json['dataset_ids'].first['value'])
      expect(obj.security_privacy_statements.first.title).to eql(@json['security_and_privacy_statements'].first['title'])
      expect(obj.technical_resources.first.description).to eql(@json['technical_resources'].first['description'])
      expect(obj.metadata.first.description).to eql(@json['metadata'].first['description'])
      expect(obj.dataset_keywords.length).to eql(@json['keywords'].length)
      expect(obj.dataset_keywords.first.keyword.value).to eql(@json['keywords'].first)
      expect(obj.distributions.first.title).to eql(@json['distributions'].first['title'])
    end

    it 'returns the existing record if the identifier already exists' do
      dataset = create(:dataset, :complete)
      ident = dataset.identifiers.first
      obj = Dataset.from_json(provenance: ident.provenance,
                              json: hash_to_json(hash: {
                                                   title: Faker::Lorem.sentence,
                                                   dataset_ids: [{
                                                     category: ident.category,
                                                     value: ident.value
                                                   }]
                                                 }))
      expect(obj.new_record?).to eql(false)
      expect(obj.id).to eql(dataset.id)
      expect(obj.identifiers.length).to eql(dataset.identifiers.length)
    end

    it 'finds the existing record rather than creating a new instance' do
      dataset = create(:dataset, data_management_plan: create(:data_management_plan, project: create(:project)),
                                 title: @jsons['minimal']['title'], dataset_type: 'dataset')
      obj = Dataset.from_json(
        provenance: Faker::Lorem.word,
        data_management_plan: dataset.data_management_plan,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(dataset.id).to eql(obj.id)
    end
  end
end
