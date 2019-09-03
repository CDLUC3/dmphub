# frozen_string_literal: true

FactoryBot.define do
  factory :award do
    project
    funder_uri                { Faker::Internet.url }
    amount                    { Faker::Number.decimal(l_digits: 2) }
    currency_type             { Faker::Currency.code }

    after :create do |award|
      create(:award_status, award: award)
    end
  end
end
