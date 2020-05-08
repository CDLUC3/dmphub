# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it 'validates uniqueness of email' do
      subject = create(:person)
      expect(subject).to validate_uniqueness_of(:email).case_insensitive
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:data_management_plans) }
    it { is_expected.to have_many(:projects) }
    it { is_expected.to have_many(:organizations) }
  end

  it 'factory can produce a valid model' do
    model = create(:person)
    expect(model.valid?).to eql(true)
  end

  describe 'errors' do
    before :each do
      @model = build(:person)
    end
    it 'includes organization errors' do
      @model.organizations << build(:organization, name: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Name can\'t be blank')).to eql(true)
    end
    it 'includes identifier errors' do
      @model.identifiers << build(:identifier, category: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Category can\'t be blank')).to eql(true)
    end
  end

  describe 'cascading deletes' do
    it 'does not delete associated data_management_plans' do
      model = create(:person, :complete)
      dmp = create(:data_management_plan, project: create(:project), persons: [model])
      model.destroy
      expect(DataManagementPlan.last).to eql(dmp)
    end
    it 'does not delete associated organizations' do
      org = create(:organization)
      model = create(:person, organizations: [org])
      model.destroy
      expect(Organization.last).to eql(org)
    end
    it 'deletes associated identifiers' do
      model = create(:person, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end

  describe 'from_json!' do
    it 'returns the existing record if the email already exists' do
      person = create(:person)
      obj = Person.from_json!(
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
        expect(obj.identifiers.first.value).to eql(@json['contactIds'].first['value'])
        expect(obj.identifiers.first.category).to eql('url')
      end

      it 'complete JSON creates a valid Person instance' do
        obj = validate_complete_json_to_model(clazz: Person, jsons: @jsons)
        expect(obj.name).to eql(@json['name'])
        expect(obj.email).to eql(@json['mbox'])
        expect(obj.identifiers.first.value).to eql(@json['contactIds'].first['value'])
        expect(obj.identifiers.first.category).to eql(@json['contactIds'].first['category'])
      end

      it 'returns the existing record if the contactId already exists' do
        person = create(:person, :complete)
        ident = person.identifiers.first
        obj = Person.from_json!(provenance: ident.provenance,
                               json: hash_to_json(hash: {
                                                    name: Faker::Lorem.word,
                                                    mbox: Faker::Internet.unique.email,
                                                    contactIds: [
                                                      category: ident.category,
                                                      value: ident.value
                                                    ]
                                                  }))
        expect(obj.new_record?).to eql(false)
        expect(obj.id).to eql(person.id)
        expect(obj.identifiers.length).to eql(person.identifiers.length)
      end

      it 'creates a new record' do
        obj = Person.from_json!(
          provenance: Faker::Lorem.word,
          json: @jsons['minimal']
        )
        expect(obj.new_record?).to eql(false)
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
        expect(obj.identifiers.first.value).to eql(@json['staffIds'].first['value'])
        expect(obj.identifiers.first.category).to eql(@json['staffIds'].first['category'])
      end

      it 'returns the existing record if the staffId already exists' do
        person = create(:person, :complete, identifier_count: 3)
        ident = person.identifiers.first
        obj = Person.from_json!(provenance: ident.provenance,
                               json: hash_to_json(hash: {
                                                    name: Faker::Lorem.word,
                                                    mbox: Faker::Internet.unique.email,
                                                    staffIds: [{
                                                      category: ident.category,
                                                      value: ident.value
                                                    }, {
                                                      category: 'url',
                                                      value: Faker::Lorem.word
                                                    }]
                                                  }))
        expect(obj.new_record?).to eql(false)
        expect(obj.id).to eql(person.id)
      end

      it 'creates a new record' do
        obj = Person.from_json!(
          provenance: Faker::Lorem.word,
          json: @jsons['minimal']
        )
        expect(obj.new_record?).to eql(false)
      end
    end
  end
end
