# frozen_string_literal: true

FactoryBot.define do
  factory :contributors_data_management_plan do
    role { ContributorsDataManagementPlan.roles.keys.sample }
  end
end
