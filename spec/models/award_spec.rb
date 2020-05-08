# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Award, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:organization) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to define_enum_for(:status).with(Award.statuses.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:identifiers) }
  end

  describe 'errors' do
    before :each do
      @model = build(:award)
    end
    it 'includes organization errors' do
      @model.organization = build(:organization, name: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Name can\'t be blank')).to eql(true)
    end
    it 'includes identifier errors' do
      @model.identifiers << build(:identifier, category: nil)
      @model.validate
      expect(@model.errors.full_messages.include?('Category can\'t be blank')).to eql(true)
    end
  end

  it 'factory can produce a valid model' do
    model = create(:award, organization: build(:organization))
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the project' do
      project = create(:project)
      model = create(:award, :complete, project: project)
      model.destroy
      expect(Project.last).to eql(project)
    end
    it 'does not delete the organization' do
      organization = create(:organization)
      model = create(:award, :complete, organization: organization)
      model.destroy
      expect(Organization.last).to eql(organization)
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
      @jsons = open_json_mock(file_name: 'awards.json')
    end

    it 'invalid JSON does not create a valid Award instance' do
      validate_invalid_json_to_model(clazz: Award, jsons: @jsons, project: @project)
    end

    it 'minimal JSON creates a valid Award instance' do
      obj = validate_minimal_json_to_model(clazz: Award, jsons: @jsons, project: @project)
      expect(obj.organization.dois.first.value).to eql(@json['funderId'])
      expect(obj.status).to eql(@json['fundingStatus'])
    end

    it 'complete JSON creates a valid Award instance' do
      obj = validate_complete_json_to_model(clazz: Award, jsons: @jsons, project: @project)
      expect(obj.status).to eql(@json['fundingStatus'])
      expect(obj.identifiers.first.value).to eql(@json['grantId'])
      expect(obj.organization.present?).to eql(true)
      expect(obj.organization.name).to eql(@json['funderName'])
      expect(obj.organization.dois.first.value).to eql(@json['funderId'])
    end

    it 'finds the existing record if the grantId exists' do
      org = create(:organization, name: @jsons['complete']['funderName'])
      award = create(:award, project: @project, organization: org, status: 'applied')
      create(:identifier, identifiable: award, value: @jsons['complete']['grantId'])
      obj = Award.from_json!(provenance: Faker::Lorem.word, project: @project.reload, json: @jsons['complete'])
      expect(obj.new_record?).to eql(false)
      expect(award.id).to eql(obj.id)
    end

    it 'finds the existing record if there is a record for the funder that is not rejected/granted' do
      org = create(:organization, name: @jsons['minimal']['funderName'])
      award = create(:award, project: @project, organization: org, status: 'planned')
      obj = Award.from_json!(provenance: Faker::Lorem.word, project: @project.reload, json: @jsons['minimal'])
      expect(obj.new_record?).to eql(false)
      expect(award.id).to eql(obj.id)
    end

    it 'creates a new record' do
      obj = Award.from_json!(
        provenance: Faker::Lorem.word,
        project: @project,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
    end
  end
end
