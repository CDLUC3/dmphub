# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataManagementPlan, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to have_many(:identifiers) }
    it { is_expected.to have_many(:persons) }
    it { is_expected.to have_many(:costs) }
    it { is_expected.to have_many(:datasets) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:oauth_authorization) }
  end

  it 'factory can produce a valid model' do
    model = build(:data_management_plan, project: build(:project))
    expect(model.valid?).to eql(true)
  end

  describe 'errors' do
    before :each do
      @model = build(:data_management_plan, project: build(:project))
    end
    it 'includes person errors' do
      @model.person_data_management_plans << build(:person_data_management_plan, person: build(:person, name: nil), role: 'author')
      @model.validate
      expect(@model.errors.full_messages.include?('Name can\'t be blank')).to eql(true)
    end
    it 'includes person_data_management_plan errors' do
      @model.person_data_management_plans << build(:person_data_management_plan, person: build(:person), role: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Name can\'t be blank')).to eql(true)
    end
    it 'includes cost errors' do
      @model.costs << build(:cost, title: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Title can\'t be blank')).to eql(true)
    end
    it 'includes dataset errors' do
      @model.datasets << build(:dataset, title: nil)
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
    before :each do
      @project = create(:project)
      @model = create(:data_management_plan, project: @project)
    end
    it 'does not delete the project' do
      @model.destroy
      expect(Project.last).to eql(@project)
    end
    it 'does not delete associated persons' do
      person = create(:person)
      @model.person_data_management_plans << create(:person_data_management_plan, person: person, role: 'author')
      @model.save
      @model.destroy
      expect(Person.where(id: person.id).any?).to eql(true)
    end
    it 'deletes associated person_data_management_plans' do
      pdmp = create(:person_data_management_plan, person: create(:person), role: 'author')
      @model.person_data_management_plans << pdmp
      @model.save
      @model.destroy
      expect(PersonDataManagementPlan.where(id: pdmp.id).empty?).to eql(true)
    end
    it 'deletes associated costs' do
      cost = create(:cost)
      @model.costs << cost
      @model.save
      @model.destroy
      expect(Cost.where(id: cost.id).empty?).to eql(true)
    end
    it 'deletes associated datasets' do
      dataset = create(:dataset)
      @model.datasets << dataset
      @model.destroy
      expect(Dataset.where(id: dataset.id).empty?).to eql(true)
    end
    it 'deletes associated identifiers' do
      model = create(:metadatum, :complete)
      identifier = model.identifiers.first
      model.destroy
      expect(Identifier.where(id: identifier.id).empty?).to eql(true)
    end
  end

  describe 'from_json!' do
    before(:each) do
      @project = build(:project)
      @jsons = open_json_mock(file_name: 'data_management_plans.json')
    end

    it 'invalid JSON does not create a valid DataManagementPlan instance' do
      validate_invalid_json_to_model(clazz: DataManagementPlan, jsons: @jsons)
    end

    it 'minimal JSON creates a valid DataManagementPlan instance' do
      obj = validate_minimal_json_to_model(clazz: DataManagementPlan, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.language).to eql('en')
      expect(ConversionService.boolean_to_yes_no_unknown(obj.ethical_issues)).to eql('unknown')
      contact = obj.person_data_management_plans.select { |pdmp| pdmp.role == 'primary_contact' }.first
      expect(contact.person.email).to eql(@json['contact']['mbox'])
    end

    it 'complete JSON creates a valid DataManagementPlan instance' do
      obj = validate_complete_json_to_model(clazz: DataManagementPlan, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.language).to eql(@json['language'])
      expect(ConversionService.boolean_to_yes_no_unknown(obj.ethical_issues)).to eql(@json['ethicalIssuesExist'])
      expect(obj.ethical_issues_report).to eql(@json['ethicalIssuesReport'])
      expect(obj.ethical_issues_description).to eql(@json['ethicalIssuesDescription'])
      contact = obj.person_data_management_plans.select { |pdmp| pdmp.role == 'primary_contact' }.first
      expect(contact.person.email).to eql(@json['contact']['mbox'])
      person = obj.person_data_management_plans.reject { |pdmp| pdmp.role == 'primary_contact' }.first
      expect(person.person.email).to eql(@json['dmStaff'].first['mbox'])
      expect(obj.project.title).to eql(@json['project']['title'])
      expect(obj.costs.first.title).to eql(@json['costs'].first['title'])
      expect(obj.datasets.first.title).to eql(@json['datasets'].first['title'])
    end

    it 'returns the existing record if the identifier already exists' do
      dmp = create(:data_management_plan, :complete, project: @project)
      ident = dmp.identifiers.first
      obj = DataManagementPlan.from_json!(provenance: ident.provenance,
                                         project: @project,
                                         json: hash_to_json(hash: {
                                                              title: Faker::Lorem.sentence,
                                                              contact: {
                                                                name: Faker::Lorem.word,
                                                                mbox: Faker::Internet.email,
                                                                contactIds: [{
                                                                  category: 'orcid',
                                                                  value: Faker::Number.number(digits: 9)
                                                                }]
                                                              },
                                                              dmpIds: [{
                                                                category: ident.category,
                                                                value: ident.value
                                                              }]
                                                            }))
      expect(obj.new_record?).to eql(false)
      expect(obj.id).to eql(dmp.id)
      expect(obj.identifiers.length).to eql(dmp.identifiers.length)
    end

    it 'finds the existing record rather than creating a new instance' do
      dmp = create(:data_management_plan, title: @jsons['minimal']['title'])
      obj = DataManagementPlan.from_json!(
        provenance: Faker::Lorem.word,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(dmp.id).to eql(obj.id)
    end
  end

  context 'instance methods' do
    before(:each) do
      @dmp = create(:data_management_plan, :complete)
    end

    describe 'primary_contact' do
      it 'returns the primary_contact and only the primary_contact' do
        expect(@dmp.primary_contact.is_a?(PersonDataManagementPlan)).to eql(true)
        expect(@dmp.primary_contact).to eql(PersonDataManagementPlan
          .where(role: 'primary_contact', data_management_plan_id: @dmp.id).first)
      end
    end

    describe 'persons' do
      before(:each) do
        @persons = @dmp.persons
      end
      it 'does not include the primary_contact' do
        expect(@persons.include?(@dmp.primary_contact)).to eql(false)
      end
      it 'includes all non-primary_contact persons' do
        PersonDataManagementPlan.where(data_management_plan_id: @dmp_id).where.not(role: 'primary_contact').each do |p|
          expect(@persons.include?(p)).to eql(true)
        end
      end
    end
  end
end
