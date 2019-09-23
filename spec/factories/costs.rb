# frozen_string_literal: true

FactoryBot.define do
  factory :cost do
    title                 { Faker::Lorem.sentence }
    description           { Faker::Lorem.paragraph }
    value                 { Faker::Number.decimal(l_digits: 2) }
    currency_code         { %w[usd gbd cad].sample }
  end
end
