# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors
#
#  id             :bigint           not null, primary key
#  name           :string(255)      not null
#  email          :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  affiliation_id :bigint
#  provenance_id  :bigint
#
FactoryBot.define do
  factory :contributor do
    provenance
    name  { Faker::Music::PearlJam.unique.musician }
    email { Faker::Internet.unique.email }

    trait :complete do
      transient do
        identifier_count { 1 }
        data_management_plan_count { 1 }
      end

      before :create do |contributor, _evaluator|
        contributor.affiliation = create(:affiliation, :complete) unless contributor.affiliation.present?
      end

      after :create do |contributor, evaluator|
        evaluator.identifier_count.times do
          contributor.identifiers << create(:identifier, category: 'orcid', identifiable: contributor,
                                                         descriptor: 'is_identified_by', provenance: contributor.provenance)
        end
        evaluator.data_management_plan_count.times do
          dmp = build(:data_management_plan)
          cdmp = build(:contributors_data_management_plan, provenance: contributor.provenance,
                                                           data_management_plan: dmp)
          contributor.contributors_data_management_plans << cdmp
        end
        contributor.save
      end
    end
  end
end
