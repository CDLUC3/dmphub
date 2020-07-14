# frozen_string_literal: true

FactoryBot.define do
  factory :alteration do
    trait :for_affiliation do
      association :alterable, factory: :affiliation
    end
    trait :for_contributor_data_management_plan do
      association :alterable, factory: :contributor_data_management_plan
    end
    trait :for_contributor do
      association :alterable, factory: :contributor
    end
    trait :for_cost do
      association :alterable, factory: :cost
    end
    trait :for_data_management_plan do
      association :alterable, factory: :data_management_plan
    end
    trait :for_dataset do
      association :alterable, factory: :dataset
    end
    trait :for_distribution do
      association :alterable, factory: :distribution
    end
    trait :for_funding do
      association :alterable, factory: :funding
    end
    trait :for_host do
      association :alterable, factory: :host
    end
    trait :for_identifier do
      association :alterable, factory: :identifier
    end
    trait :for_keyword do
      association :alterable, factory: :keyword
    end
    trait :for_license do
      association :alterable, factory: :license
    end
    trait :for_metadatum do
      association :alterable, factory: :metadatum
    end
    trait :for_project do
      association :alterable, factory: :project
    end
    trait :for_security_privacy_statement do
      association :alterable, factory: :security_privacy_statement
    end
    trait :for_technical_resource do
      association :alterable, factory: :technical_resource
    end
  end
end
