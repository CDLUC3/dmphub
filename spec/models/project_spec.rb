# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:start_on) }
    it { is_expected.to validate_presence_of(:end_on) }
  end

  context 'associations' do
    it { is_expected.to have_many(:data_management_plans) }
    it { is_expected.to have_many(:awards) }
  end

  it 'factory can produce a valid model' do
    model = create(:project)
    expect(model.valid?).to eql(true)
  end

  describe 'errors' do
    before :each do
      @project = build(:project)
    end
    it 'includes data_management_plan errors' do
      @project.data_management_plans << build(:data_management_plan, title: nil)
      @project.validate
      expect(@project.errors.full_messages.include?('Title can\'t be blank')).to eql(true)
    end
    it 'includes award errors' do
      @project.awards << build(:award, organization: nil)
      @project.validate
      expect(@project.errors.full_messages.include?('Organization can\'t be blank')).to eql(true)
    end
  end

  describe 'cascading deletes' do
    it 'deletes the associated data_management_plans' do
      dmp = create(:data_management_plan)
      model = create(:project, data_management_plans: [dmp])
      model.destroy
      expect(Project.last).to eql(nil)
      expect(DataManagementPlan.last).not_to eql(dmp)
    end
    it 'deletes the associated awards' do
      model = create(:project)
      award = create(:award, project: model, organization: create(:organization))
      model.destroy
      expect(DataManagementPlan.last).not_to eql(award)
    end
  end

  describe 'from_json!' do
    before(:each) do
      @jsons = open_json_mock(file_name: 'projects.json')
    end

    it 'invalid JSON does not create a valid Project instance' do
      validate_invalid_json_to_model(clazz: Project, jsons: @jsons)
    end

    it 'minimal JSON creates a valid Project instance' do
      obj = validate_minimal_json_to_model(clazz: Project, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.start_on.to_s).to eql(@json['startOn'])
      expect(obj.end_on.to_s).to eql(@json['endOn'])
    end

    it 'complete JSON creates a valid Project instance' do
      obj = validate_complete_json_to_model(clazz: Project, jsons: @jsons)
      expect(obj.title).to eql(@json['title'])
      expect(obj.description).to eql(@json['description'])
      expect(obj.start_on.to_s).to eql(@json['startOn'])
      expect(obj.end_on.to_s).to eql(@json['endOn'])
      expect(obj.awards.first.organization.identifiers.first.value).to eql(@json['funding'].first['funderId'])
    end

    it 'finds the existing record rather than creating a new instance' do
      project = create(:project, title: @jsons['minimal']['title'])
      obj = Project.from_json!(
        provenance: Faker::Lorem.word,
        json: @jsons['minimal']
      )
      expect(obj.new_record?).to eql(false)
      expect(project.id).to eql(obj.id)
    end
  end
end
