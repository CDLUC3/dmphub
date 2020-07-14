# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContributorsDataManagementPlan, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to define_enum_for(:role).with_values(ContributorsDataManagementPlan.roles.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:data_management_plan) }
    it { is_expected.to belong_to(:contributor) }
    it { is_expected.to belong_to(:provenance) }
    it { is_expected.to have_many(:alterations) }
  end

  it 'factory can produce a valid model' do
    model = create(:contributors_data_management_plan,
                   data_management_plan: create(:data_management_plan, project: create(:project)),
                   contributor: create(:contributor, provenance: build(:provenance)))
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    before(:each) do
      @provenance = create(:provenance)
      @contributor = create(:contributor, provenance: @provenance)
      @dmp = create(:data_management_plan, provenance: @provenance,
                                           project: create(:project, provenance: @provenance))
      @model = create(:contributors_data_management_plan, data_management_plan: @dmp,
                                                          contributor: @contributor, provenance: @provenance)
      @model.destroy
    end

    it 'does not delete the contributor' do
      expect(Contributor.last).to eql(@contributor)
    end
    it 'does not delete the organization' do
      expect(DataManagementPlan.last).to eql(@dmp)
    end
  end
end
