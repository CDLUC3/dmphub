# frozen_string_literal: true

FactoryBot.define do
  factory :person_data_management_plan do
    data_management_plan  { create(:data_management_plan) }
    person                { create(:person, :complete) }
    role                  { PersonDataManagementPlan.roles.keys.sample }
  end
end
