# frozen_string_literal: true

FactoryBot.define do
  factory :technical_resource do
    title       { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }

    before :create do |technical_resource|
      technical_resource.provenance = build(:provenance) unless technical_resource.provenance.present?
    end
  end
end
