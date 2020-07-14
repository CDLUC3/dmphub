# frozen_string_literal: true

FactoryBot.define do
  factory :distribution do
    title                 { Faker::Lorem.sentence }
    description           { Faker::Lorem.paragraph }
    format                { Faker::Lorem.word }
    byte_size             { Faker::Number.decimal(l_digits: 8) }
    access_url            { Faker::Internet.url }
    download_url          { Faker::Internet.url }
    data_access           { Distribution.data_accesses.keys.sample }
    available_until       { Time.now + 30.days }

    before :create do |distribution|
      distribution.provenance = build(:provenance) unless distribution.provenance.present?
    end

    trait :complete do
      transient do
        license_count { 1 }
      end

      after :create do |distribution, evaluator|
        distribution.host = create(:host, provenance: distribution.provenance) unless distribution.host.present?

        evaluator.license_count.times do
          distribution.licenses << create(:license, provenance: distribution.provenance)
        end
      end
    end
  end
end
