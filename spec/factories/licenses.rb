# frozen_string_literal: true

FactoryBot.define do
  factory :license do
    distribution { create(:distribution) }
    license_uri  { Faker::Internet.url }
    start_date   { Time.now + 30.days }
  end
end
