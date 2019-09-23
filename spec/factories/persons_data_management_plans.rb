# frozen_string_literal: true

FactoryBot.define do
  factory :person_data_management_plan do
    role { PersonDataManagementPlan.roles.keys.sample }
  end
end
