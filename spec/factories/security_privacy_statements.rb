# frozen_string_literal: true

FactoryBot.define do
  factory :security_privacy_statement do
    dataset
    title       { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
  end
end
