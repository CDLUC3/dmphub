# frozen_string_literal: true

# == Schema Information
#
# Table name: affiliations
#
#  id              :bigint           not null, primary key
#  name            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  alternate_names :text(65535)
#  attrs           :json             not null
#  types           :text(65535)
#  provenance_id   :bigint
#
FactoryBot.define do
  factory :affiliation do
    provenance
    name            { Faker::Company.unique.name }
    attrs           { {} }
    alternate_names { [] }
    types           { [] }

    trait :complete do
      transient do
        identifier_count { 1 }
      end

      after :create do |affiliation, evaluator|
        evaluator.identifier_count.times do
          affiliation.identifiers << create(:identifier, category: 'ror', identifiable: affiliation,
                                                         descriptor: 'is_identified_by', provenance: affiliation.provenance)
        end
      end
    end
  end
end
