# frozen_string_literal: true

FactoryBot.define do
  factory :keyword do |_award|
    value { Faker::Lorem.unique.word }
  end
end
