# frozen_string_literal: true

FactoryBot.define do
  factory :keyword do |award|
    value   { Faker::Lorem.unique.word }
  end
end
