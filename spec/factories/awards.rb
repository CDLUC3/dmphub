# frozen_string_literal: true

FactoryBot.define do
  factory :award do |_award|
    status     { Award.statuses.keys.sample }

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      before :create do |award, evaluator|
        award.organization = create(:organization, :complete) unless award.organization.present?
      end

      after :create do |award, evaluator|
        evaluator.identifier_count.times do
          award.identifiers << create(:identifier, category: 'url', identifiable: award, descriptor: 'funded_by')
        end
      end
    end
  end
end
