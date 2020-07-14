# frozen_string_literal: true

FactoryBot.define do
  # This base factory is not meant to be used directly, use one of the ones below
  factory :identifier do
    category        { Identifier.categories.keys.sample }
    provenance      { Faker::Lorem.word.downcase }
    value           { SecureRandom.uuid }
    descriptor      { Identifier.descriptors.keys.sample }

    before :create do |identifier|
      identifier.provenance = build(:provenance) unless identifier.provenance.present?
    end
  end
end
