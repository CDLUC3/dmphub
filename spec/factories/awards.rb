# frozen_string_literal: true

FactoryBot.define do
  factory :award do |award|
    project
    funder_uri { Faker::Internet.url }
    status     { Award.statuses.keys.sample }

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      after :create do |dataset, evaluator|
        evaluator.identifier_count.times do
          dataset.identifiers << create(:award_identifier, category: 'url')
        end
      end
    end
  end
end
