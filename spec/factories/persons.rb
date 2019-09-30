# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    name  { Faker::Movies::StarWars.character }
    email { Faker::Internet.unique.email }

    trait :complete do
      transient do
        identifier_count { 1 }
        organization_count { 1 }
      end

      after :create do |person, evaluator|
        evaluator.identifier_count.times do
          person.identifiers << create(:identifier, category: 'orcid', identifiable: person, descriptor: 'identified_by')
        end
        evaluator.organization_count.times do
          person.organizations << create(:organization)
        end
        person.save
      end
    end
  end
end
