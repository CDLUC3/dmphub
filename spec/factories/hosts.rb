# frozen_string_literal: true

FactoryBot.define do
  factory :host do
    distribution
    title                 { Faker::Lorem.sentence }
    description           { Faker::Lorem.paragraph }
    supports_versioning   { [nil, true, false].sample }
    backup_type           { Faker::Lorem.word }
    backup_frequency      { Faker::Lorem.word }
    storage_type          { Faker::Lorem.word }
    availability          { Faker::Lorem.word }
    geo_location          { Faker::Movies::StarWars.planet }

    trait :complete do
      transient do
        identifiers_count { 1 }
      end

      after :create do |host, evaluator|
        evaluator.identifiers_count.times do
          host.identifiers << create(:host_identifier)
        end
      end
    end
  end
end
