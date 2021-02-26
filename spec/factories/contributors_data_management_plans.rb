# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors_data_management_plans
#
#  id                      :bigint           not null, primary key
#  contributor_id          :bigint
#  data_management_plan_id :bigint
#  role                    :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  provenance_id           :bigint
#
FactoryBot.define do
  factory :contributors_data_management_plan do
    role { ContributorsDataManagementPlan.roles.keys.sample }

    before :create do |cdmp|
      cdmp.provenance = build(:provenance) unless cdmp.provenance.present?
    end
  end
end
