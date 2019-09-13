# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  context 'associations' do
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:data_management_plans) }
    it { is_expected.to have_many(:organizations) }
  end

  it 'factory can produce a valid model' do
    model = create(:person)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    context 'dataset contact' do
      before(:each) do
        @jsons = open_json_mock(file_name: 'persons.json').fetch('dataset_contact', {})
      end

      it 'invalid JSON does not create a valid Person instance' do
        validate_invalid_json_to_model(clazz: Person, jsons: @jsons)
      end

      it 'minimal JSON creates a valid Person instance' do
        obj = validate_minimal_json_to_model(clazz: Person, jsons: @jsons)
        expect(obj.name).to eql(@json['name'])
        expect(obj.email).to eql(@json['mbox'])
        expect(obj.identifiers.first.value).to eql(@json['contact_ids'].first['value'])
        expect(obj.identifiers.first.category).to eql('url')
      end

      it 'complete JSON creates a valid Person instance' do
        obj = validate_complete_json_to_model(clazz: Person, jsons: @jsons)
        expect(obj.name).to eql(@json['name'])
        expect(obj.email).to eql(@json['mbox'])
        expect(obj.identifiers.first.value).to eql(@json['contact_ids'].first['value'])
        expect(obj.identifiers.first.category).to eql(@json['contact_ids'].first['category'])
      end
    end

    context 'dataset dm_staff' do
      before(:each) do
        @jsons = open_json_mock(file_name: 'persons.json').fetch('dataset_dm_staff', {})
      end

      it 'invalid JSON does not create a valid Person instance' do
        validate_invalid_json_to_model(clazz: Person, jsons: @jsons)
      end

      it 'minimal JSON creates a valid Person instance' do
        obj = validate_minimal_json_to_model(clazz: Person, jsons: @jsons)
        expect(obj.name).to eql(@json['name'])
      end

      it 'complete JSON creates a valid Person instance' do
        obj = validate_complete_json_to_model(clazz: Person, jsons: @jsons)
        expect(obj.name).to eql(@json['name'])
        expect(obj.email).to eql(@json['mbox'])
        expect(obj.identifiers.first.value).to eql(@json['user_ids'].first['value'])
        expect(obj.identifiers.first.category).to eql(@json['user_ids'].first['category'])
      end
    end
  end

  context 'callbacks' do
    describe 'creatable?' do
      xit 'returns false if the email already exists' do
        model = create(:person)
        model2 = build(:person, email: model.email)
        expect(model2.send(:creatable?)).to eql(false)
      end

      xit 'returns false one of the identifiers already exists' do
        model = create(:person, :complete)
        model2 = build(:person, :complete)
        model2.identifiers << model.identifiers.first
        expect(model2.send(:creatable?)).to eql(false)
      end

      xit 'returns true if the person does not already exist' do
        model = build(:person, :complete)
        expect(model.send(:creatable?)).to eql(true)
      end
    end
  end
end
