# frozen_string_literal: true

FactoryBot.define do
  factory :identifier do
    category     { Identifier.categories.keys.sample }
    value        { Faker::Lorem.word }
  end
end
