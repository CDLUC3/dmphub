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
    name  { Faker::Music::PearlJam.musician }
    email { Faker::Internet.unique.email }

    trait :complete do
      transient do
        identifier_count { 1 }
        role_count { 1 }
      end

      before :create do |contributor, evaluator|
        evaluator.role_count.times do
          contributor.identifiers << create(:identifier, category: 'credit', identifiable: contributor,
                                                         descriptor: 'is_identified_by', provenance: contributor.provenance)
        end
        contributor.affiliation = create(:affiliation, :complete) unless contributor.affiliation.present?
      end

      after :create do |contributor, evaluator|
        evaluator.identifier_count.times do
          contributor.identifiers << create(:identifier, category: 'orcid', identifiable: contributor,
                                                         descriptor: 'is_identified_by', provenance: contributor.provenance)
        end
        contributor.save
      end
    end
  end
end
