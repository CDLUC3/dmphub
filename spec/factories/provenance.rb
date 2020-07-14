# frozen_string_literal: true

FactoryBot.define do
  factory :provenance do
    name        { Faker::Lorem.unique.word }
    description { Faker::Lorem.paragraph }
  end
end
