# frozen_string_literal: true

FactoryBot.define do
  factory :award do |award|
    project
    funder_uri { Faker::Internet.url }
  end

  factory :award_with_statuses, parent: :award do
    transient do
      status_count { 1 }
    end

    after :create do |award, evaluator|
      create_list :award_status, evaluator.status_count, award: award
    end
  end
end
