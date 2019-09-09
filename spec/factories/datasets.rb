# frozen_string_literal: true

FactoryBot.define do
  factory :dataset do
    data_management_plan        { create(:data_management_plan) }
    title                       { Faker::Movies::StarWars.wookiee_sentence }
    dataset_type                { Dataset.dataset_types.keys.sample }
    sensitive_data              { [0, 1, 2].sample }
    personal_data               { [0, 1, 2].sample }

    trait :complete do
      transient do
        identifier_count { 1 }
        description_count { 1 }
        quality_assurance_count { 1 }
        preservation_statement_count { 1 }
      end

      after :create do |dataset, evaluator|
        evaluator.identifier_count.times do
          dataset.identifiers << create(:dataset_identifier)
        end
        evaluator.description_count.times do
          dataset.descriptions << create(:dataset_description, category: 'abstract')
        end
        evaluator.quality_assurance_count.times do
          dataset.descriptions << create(:dataset_description, category: 'quality_assurance')
        end
        evaluator.preservation_statement_count.times do
          dataset.descriptions << create(:dataset_description, category: 'preservation_statement')
        end
      end
    end
  end
end
