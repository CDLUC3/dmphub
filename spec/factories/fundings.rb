# frozen_string_literal: true

# == Schema Information
#
# Table name: fundings
#
#  id             :bigint           not null, primary key
#  project_id     :bigint
#  status         :integer          default("planned"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  affiliation_id :bigint
#  provenance_id  :bigint
#
FactoryBot.define do
  factory :funding do |_funding|
    status { Funding.statuses.keys.sample }

    before :create do |funding|
      funding.provenance = build(:provenance) unless funding.provenance.present?
    end

    trait :complete do
      transient do
        identifier_count { 1 }
        funded_affiliation_count { 1 }
      end

      before :create do |funding, _evaluator|
        funding.affiliation = create(:affiliation, :complete) unless funding.affiliation.present?
      end

      after :create do |funding, evaluator|
        # Ensure affiliation has a Fundref ID
        unless funding.fundrefs.any?
          funding.affiliation.identifiers << create(:identifier, category: 'fundref', identifiable: funding.affiliation,
                                                                 descriptor: 'is_identified_by', provenance: funding.provenance)
        end

        evaluator.identifier_count.times do
          funding.identifiers << create(:identifier, category: 'url', identifiable: funding, descriptor: 'is_funded_by',
                                                     provenance: funding.provenance)
        end
        evaluator.funded_affiliation_count.times do
          funding.funded_affiliations << create(:affiliation, :complete)
        end
      end
    end
  end
end
