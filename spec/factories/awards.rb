# frozen_string_literal: true

FactoryBot.define do
  factory :award do |award|
    funder_uri { Faker::Internet.url }
    status     { Award.statuses.keys.sample }

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      after :create do |award, evaluator|
        evaluator.identifier_count.times do
          award.identifiers << create(:identifier, category: 'url', identifiable: award)
        end
      end
    end
  end
end
