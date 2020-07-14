# frozen_string_literal: true

FactoryBot.define do
  factory :funding do |_funding|
    status { Funding.statuses.keys.sample }

    before :create do |funding|
      funding.provenance = build(:provenance) unless funding.provenance.present?
    end

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      before :create do |funding, _evaluator|
        funding.affiliation = create(:affiliation, :complete) unless funding.affiliation.present?
      end

      after :create do |funding, evaluator|
        evaluator.identifier_count.times do
          funding.identifiers << create(:identifier, category: 'url', identifiable: funding, descriptor: 'funded_by')
        end
      end
    end
  end
end
