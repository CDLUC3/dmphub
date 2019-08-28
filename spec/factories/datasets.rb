# frozen_string_literal: true

FactoryBot.define do
  factory :dataset do
    data_management_plan
    title                   { Faker::Movies::StarWars.wookiee_sentence }
    dataset_type            { Dataset.dataset_types.keys.sample }
    sensitive_data          { Faker::Boolean.boolean }
    personal_data           { Faker::Boolean.boolean }
    sequence(:identifiers)  { |n| create(:identifier) }
    sequence(:descriptions) { |n| create(:description) }
  end
end
