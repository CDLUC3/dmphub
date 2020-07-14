# frozen_string_literal: true

FactoryBot.define do
  factory :security_privacy_statement do
    title       { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }

    before :create do |security_privacy_statement|
      security_privacy_statement.provenance = build(:provenance) unless security_privacy_statement.provenance.present?
    end
  end
end
