# frozen_string_literal: true

FactoryBot.define do
  factory :license do
    license_ref  { Faker::Internet.url }
    start_date   { Time.now + 30.days }

    before :create do |license|
      license.provenance = build(:provenance) unless license.provenance.present?
    end
  end
end
