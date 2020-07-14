# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:start_on) }
    it { is_expected.to validate_presence_of(:end_on) }

    it 'validates start_on comes before end_on' do
      project = build(:project, :complete, start_on: (Time.now + 2.days), end_on: Time.now)
      expect(project.valid?).to eql(false)
      expect(project.errors.full_messages.include?('Start on invalid date range (Start must come before end)')).to eql(true)
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:data_management_plans) }
    it { is_expected.to have_many(:fundings) }
  end

  it 'factory can produce a valid model' do
    model = create(:project)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'deletes the associated data_management_plans' do
      dmp = create(:data_management_plan)
      model = create(:project, data_management_plans: [dmp])
      model.destroy
      expect(Project.last).to eql(nil)
      expect(DataManagementPlan.last).not_to eql(dmp)
    end
    it 'deletes the associated fundings' do
      model = create(:project)
      funding = create(:funding, project: model, affiliation: create(:affiliation))
      model.destroy
      expect(DataManagementPlan.last).not_to eql(funding)
    end
  end
end
