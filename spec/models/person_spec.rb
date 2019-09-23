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

    it 'returns the existing record if the email already exists' do
      person = create(:person, :complete)
      obj = Person.from_json(
        provenance: Faker::Lorem.word,
        json: hash_to_json(hash: {
          name: Faker::Lorem.word,
          mbox: person.email
        })
      )
      expect(obj.new_record?).to eql(false)
      expect(obj.id).to eql(person.id)
    end

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

      it 'returns the existing record if the contact_id already exists' do
        person = create(:person, :complete)
        ident = person.identifiers.first
        obj = Person.from_json(provenance: ident.provenance,
          json: hash_to_json(hash: {
            name: Faker::Lorem.word,
            mbox: Faker::Internet.unique.email,
            contact_ids: [
              category: ident.category,
              value: ident.value
            ]
          })
        )
        expect(obj.new_record?).to eql(false)
        expect(obj.id).to eql(person.id)
        expect(obj.identifiers.length).to eql(person.identifiers.length)
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

      it 'returns the existing record if the user_id already exists' do
        person = create(:person, :complete, identifier_count: 3)
        ident = person.identifiers.first
        obj = Person.from_json(provenance: ident.provenance,
          json: hash_to_json(hash: {
            name: Faker::Lorem.word,
            mbox: Faker::Internet.unique.email,
            user_ids: [{
              category: ident.category,
              value: ident.value
            },{
              category: 'url',
              value: Faker::Lorem.word
            }]
          })
        )
        expect(obj.new_record?).to eql(false)
        expect(obj.id).to eql(person.id)
        expect(obj.identifiers.length).to eql(person.identifiers.length)
      end

    end
  end
end
