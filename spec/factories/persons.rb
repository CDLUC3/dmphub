# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    name { Faker::Movies::StarWars.character }

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      after :create do |person, evaluator|
        person.identifiers << create(:person_identifier, category: 'email')

        evaluator.identifier_count.times do
          person.identifiers << create(:person_identifier)
        end
      end
    end
  end
end
