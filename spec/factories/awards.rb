# frozen_string_literal: true

FactoryBot.define do
  factory :award do
    project
    funder_uri                { Faker::Internet.url }
    amount                    { Faker::Number.decimal(l_digits: 2) }
    currency                  { Faker::Currency.code }
    sequence(:award_statuses) { |n| create(:award_status) }
  end
end
