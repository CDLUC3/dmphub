# frozen_string_literal: true

FactoryBot.define do
  factory :keyword do |_award|
    value { Faker::Lorem.unique.word }

    before :create do |keyword|
      keyword.provenance = build(:provenance) unless keyword.provenance.present?
    end
  end
end
