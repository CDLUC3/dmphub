# frozen_string_literal: true

FactoryBot.define do
  factory :contributor do
    name  { Faker::Movies::StarWars.character }
    email { Faker::Internet.unique.email }

    trait :complete do
      transient do
        identifier_count { 1 }
        role_count { 1 }
      end

      before :create do |contributor, evaluator|
        evaluator.role_count.times do
          contributor.identifiers << create(:identifier, category: 'credit', identifiable: contributor, descriptor: 'identified_by')
        end
      end

      after :create do |contributor, evaluator|
        evaluator.identifier_count.times do
          contributor.identifiers << create(:identifier, category: 'orcid', identifiable: contributor, descriptor: 'identified_by')
        end
        contributor.save
      end
    end
  end
end
