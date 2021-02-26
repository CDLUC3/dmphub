# frozen_string_literal: true

# == Schema Information
#
# Table name: costs
#
#  id                      :bigint           not null, primary key
#  data_management_plan_id :bigint
#  title                   :string(255)      not null
#  description             :text(4294967295)
#  value                   :float(24)
#  currency_code           :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  provenance_id           :bigint
#
require 'rails_helper'

RSpec.describe Cost, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:data_management_plan).optional }
  end

  it 'factory can produce a valid model' do
    model = create(:cost)
    expect(model.valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete the data_management_plan' do
      dmp = create(:data_management_plan, project: create(:project))
      model = create(:cost, data_management_plan: dmp)
      model.destroy
      expect(DataManagementPlan.last).to eql(dmp)
    end
  end
end
