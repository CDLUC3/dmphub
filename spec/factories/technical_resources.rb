# frozen_string_literal: true

FactoryBot.define do
  factory :technical_resource do
    dataset
    description { Faker::Lorem.paragraph }

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      after :create do |technical_resource, evaluator|
        evaluator.identifier_count.times do
          technical_resource.identifiers << create(:technical_resource_identifier)
        end
      end
    end
  end
end
