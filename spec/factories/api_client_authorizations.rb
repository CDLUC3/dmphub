# frozen_string_literal: true

FactoryBot.define do
  factory :api_client_authorization do
    trait :for_data_management_plan do
      association :authorizable, factory: :data_management_plan
    end
    trait :for_project do
      association :authorizable, factory: :project
    end
  end
end
