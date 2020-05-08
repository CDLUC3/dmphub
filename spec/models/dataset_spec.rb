# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dataset, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:dataset_type) }
    it { is_expected.to define_enum_for(:dataset_type).with(Dataset.dataset_types.keys) }
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

  describe 'errors' do
    before :each do
      @model = build(:dataset)
    end
    it 'includes keyword errors' do
      @model.keywords << build(:keyword, value: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Keywords is invalid')).to eql(true)
    end
    it 'includes security_privacy_statement errors' do
      @model.security_privacy_statements << build(:security_privacy_statement, title: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Title can\'t be blank')).to eql(true)
    end
    it 'includes metadatum errors' do
      @model.metadata << build(:metadatum, language: nil)
      @model.validate

      expect(@model.errors.full_messages.include?('Language can\'t be blank')).to eql(true)
    end
    it 'includes distribution errors' do
      @model.distributions << build(:distribution, title: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Title can\'t be blank')).to eql(true)
    end
    it 'includes identifier errors' do
      @model.identifiers << build(:identifier, category: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Category can\'t be blank')).to eql(true)
    end
  end

  describe 'cascading deletes' do
    it 'does not delete the data_management_plan' do
      dmp = create(:data_management_plan, project: create(:project))
      model = create(:dataset, data_management_plan: dmp)
      model.destroy
      expect(DataManagementPlan.last).to eql(dmp)
    end
    it 'does not delete associated keywords' do
      keyword = create(:keyword)
      model = create(:dataset, keywords: [keyword])
      model.destroy
      expect(Keyword.where(id: keyword.id).first).to eql(keyword)
    end
    it 'deletes associated security_privacy_statements' do
      stmt = create(:security_privacy_statement)
      model = create(:dataset, security_privacy_statements: [stmt])
      model.destroy
      expect(SecurityPrivacyStatement.where(id: stmt.id).empty?).to eql(true)
    end
    it 'deletes associated technical_resources' do
      resource = create(:technical_resource)
      model = create(:dataset, technical_resources: [resource])
      model.destroy
      expect(TechnicalResource.where(id: resource.id).empty?).to eql(true)
    end
    it 'deletes associated metadata' do
      datum = create(:metadatum)
      model = create(:dataset, metadata: [datum])
      model.destroy
      expect(Metadatum.where(id: datum.id).empty?).to eql(true)
    end
    it 'deletes associated distributions' do
      distro = create(:distribution)
      model = create(:dataset, distributions: [distro])
      model.destroy
      expect(Distribution.where(id: distro.id).empty?).to eql(true)
    end
    it 'deletes associated identifiers' do
      model = create(:dataset, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end

  describe 'from_json!' do
    before(:each) do
      @data_management_plan = build(:data_management_plan, project: build(:project))
      @jsons = open_json_mock(file_name: 'datasets.json')
    end

    it 'invalid JSON does not create a valid Dataset instance' do
      validate_invalid_json_to_model(clazz: Dataset, jsons: @jsons, data_management_plan: @data_management_plan)
    end

    it 'minimal JSON creates a valid Dataset instance' do
      obj = validate_minimal_json_to_model(clazz: Dataset, jsons: @jsons, data_management_plan: @data_management_plan)
      expect(obj.title).to eql(@json['title'])
    end

    it 'complete JSON creates a valid Dataset instance' do
      obj = validate_complete_json_to_model(clazz: Dataset, jsons: @jsons, data_management_plan: @data_management_plan)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.dataset_type).to eql(@json['type'])
      expect(obj.publication_date.to_s).to eql(@json['issued'])
      expect(obj.language).to eql(@json['language'])
      expect(ConversionService.boolean_to_yes_no_unknown(obj.personal_data)).to eql(@json['personalData'])
      expect(ConversionService.boolean_to_yes_no_unknown(obj.sensitive_data)).to eql(@json['sensitiveData'])
      expect(obj.data_quality_assurance).to eql(@json['dataQualityAssurance'])
      expect(obj.preservation_statement).to eql(@json['preservationStatement'])
      expect(obj.identifiers.first.value).to eql(@json['datasetIds'].first['value'])
      expect(obj.security_privacy_statements.first.title).to eql(@json['securityAndPrivacyStatements'].first['title'])
      expect(obj.technical_resources.first.description).to eql(@json['technicalResources'].first['description'])
      expect(obj.metadata.first.description).to eql(@json['metadata'].first['description'])
      expect(obj.dataset_keywords.length).to eql(@json['keywords'].length)
      expect(obj.dataset_keywords.first.keyword.value).to eql(@json['keywords'].first)
      expect(obj.distributions.first.title).to eql(@json['distributions'].first['title'])
    end

    it 'returns the existing record if the identifier already exists' do
      dataset = create(:dataset, :complete)
      ident = dataset.identifiers.first
      obj = Dataset.from_json!(provenance: ident.provenance,
                               data_management_plan: @data_management_plan,
                               json: hash_to_json(hash: {
                                                   title: Faker::Lorem.sentence,
                                                   datasetIds: [{
                                                     category: ident.category,
                                                     value: ident.value
                                                   }]
                                                 }))
      expect(obj.new_record?).to eql(false)
      expect(obj.id).to eql(dataset.id)
      expect(obj.identifiers.length).to eql(dataset.identifiers.length)
    end

    it 'finds the existing record rather than creating a new instance' do
      dataset = create(:dataset, data_management_plan: @data_management_plan,
                                 title: @jsons['minimal']['title'], dataset_type: 'dataset')
      obj = Dataset.from_json!(
        provenance: Faker::Lorem.word,
        data_management_plan: @data_management_plan,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(dataset.id).to eql(obj.id)
    end

    it 'creates a new record' do
      obj = Dataset.from_json!(
        provenance: Faker::Lorem.word,
        data_management_plan: @data_management_plan,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
    end
  end
end
