# frozen_string_literal: true

FactoryBot.define do
  factory :technical_resource do
    title       { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
  end
end
