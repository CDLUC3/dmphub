# frozen_string_literal: true

FactoryBot.define do
  factory :metadatum do
    description { Faker::Lorem.paragraph }
    language    { %w[en fr de es].sample }

    before :create do |metadatum|
      metadatum.provenance = build(:provenance) unless metadatum.provenance.present?
    end

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      after :create do |metadatum, evaluator|
        evaluator.identifier_count.times do
          metadatum.identifiers << create(:identifier, category: 'url', identifiable: metadatum, descriptor: Identifier.descriptors.keys.sample)
        end
      end
    end
  end
end
