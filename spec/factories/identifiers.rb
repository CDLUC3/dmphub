# frozen_string_literal: true

FactoryBot.define do
  # This base factory is not meant to be used directly, use one of the ones below
  factory :identifier do
    category     { Identifier.categories.keys.sample }
    value        { Faker::Lorem.word }
  end

  factory :award_identifier, parent: :identifier do |identifier|
    identifier.identifiable { |i| i.association(:award) }
  end

  factory :data_management_plan_identifier, parent: :identifier do |identifier|
    identifier.identifiable { |i| i.association(:data_management_plan) }
  end

  factory :dataset_identifier, parent: :identifier do |identifier|
    identifier.identifiable { |i| i.association(:dataset) }
  end

  factory :person_identifier, parent: :identifier do |identifier|
    identifier.identifiable { |i| i.association(:person) }
  end
end
