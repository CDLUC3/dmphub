# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    name { Faker::Company.unique.name }
    attrs { {} }

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      after :create do |organization, evaluator|
        evaluator.identifier_count.times do
          organization.identifiers << create(:identifier, category: 'ror', identifiable: organization, descriptor: 'identified_by')
        end
      end
    end
  end
end
