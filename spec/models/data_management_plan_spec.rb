# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataManagementPlan, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:language) }
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
    model = build(:data_management_plan)
    expect(model.valid?).to eql(true)
  end

  describe 'from_json' do
    before(:each) do
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
      expect(ConversionService.boolean_to_yes_no_unknown(obj.ethical_issues)).to eql(@json['ethical_issues_exist'])
      expect(obj.ethical_issues_report).to eql(@json['ethical_issues_report'])
      expect(obj.ethical_issues_description).to eql(@json['ethical_issues_description'])
      contact = obj.person_data_management_plans.select { |pdmp| pdmp.role == 'primary_contact' }.first
      expect(contact.person.email).to eql(@json['contact']['mbox'])
      person = obj.person_data_management_plans.select { |pdmp| pdmp.role != 'primary_contact' }.first
      expect(person.person.email).to eql(@json['dm_staff'].first['mbox'])
      expect(obj.project.title).to eql(@json['project']['title'])
      expect(obj.costs.first.title).to eql(@json['costs'].first['title'])
      expect(obj.datasets.first.title).to eql(@json['datasets'].first['title'])
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
