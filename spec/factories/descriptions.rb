# frozen_string_literal: true

FactoryBot.define do
  factory :description do
    category     { Description.categories.keys.sample }
    value        { Faker::Lorem.paragraph }
  end
end
