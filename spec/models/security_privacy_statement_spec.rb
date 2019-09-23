# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SecurityPrivacyStatement, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:dataset) }
  end

  it 'factory can produce a valid model' do
    model = create(:security_privacy_statement)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'security_privacy_statements.json')
    end

    it 'invalid JSON does not create a valid SecurityPrivacyStatement instance' do
      validate_invalid_json_to_model(clazz: SecurityPrivacyStatement, jsons: @jsons)
    end

    it 'minimal JSON creates a valid SecurityPrivacyStatement instance' do
      obj = validate_minimal_json_to_model(clazz: SecurityPrivacyStatement, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
    end

    it 'complete JSON creates a valid SecurityPrivacyStatement instance' do
      obj = validate_complete_json_to_model(clazz: SecurityPrivacyStatement, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
    end

    it 'finds the existing record rather than creating a new instance' do
      statement = create(:security_privacy_statement, dataset: create(:dataset), title: @jsons['minimal']['title'])
      obj = SecurityPrivacyStatement.from_json(
        provenance: Faker::Lorem.word,
        dataset: statement.dataset,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(statement.id).to eql(obj.id)
    end
  end
end
