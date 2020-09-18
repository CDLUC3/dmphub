# frozen_string_literal: true

FactoryBot.define do
  factory :affiliation do
    provenance
    name            { Faker::Company.unique.name }
    attrs           { {} }
    alternate_names { [] }
    types           { [] }

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      after :create do |affiliation, evaluator|
        evaluator.identifier_count.times do
          affiliation.identifiers << create(:identifier, category: 'ror', identifiable: affiliation,
                                                         descriptor: 'identified_by', provenance: affiliation.provenance)
        end
      end
    end
  end
end
