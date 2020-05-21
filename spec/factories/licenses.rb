# frozen_string_literal: true

FactoryBot.define do
  factory :license do
    license_ref  { Faker::Internet.url }
    start_date   { Time.now + 30.days }
  end
end
