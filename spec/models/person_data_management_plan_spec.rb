# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonDataManagementPlan, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to define_enum_for(:role).with(PersonDataManagementPlan.roles.keys) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:data_management_plan) }
    it { is_expected.to belong_to(:person) }
  end

  it 'factory can produce a valid model' do
    model = create(:person_data_management_plan,
                   data_management_plan: create(:data_management_plan, project: create(:project)),
                   person: create(:person))
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    before(:each) do
      @person = create(:person)
      @dmp = create(:data_management_plan, project: create(:project))
      @model = create(:person_data_management_plan, data_management_plan: @dmp, person: @person)
      @model.destroy
    end

    it 'does not delete the person' do
      expect(Person.last).to eql(@person)
    end
    it 'does not delete the organization' do
      expect(DataManagementPlan.last).to eql(@dmp)
    end
  end
end
