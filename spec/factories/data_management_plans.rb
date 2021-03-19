# frozen_string_literal: true

# == Schema Information
#
# Table name: data_management_plans
#
#  id                         :bigint           not null, primary key
#  title                      :string(255)      not null
#  language                   :string(255)      not null
#  ethical_issues             :boolean
#  description                :text(4294967295)
#  ethical_issues_description :text(4294967295)
#  ethical_issues_report      :text(4294967295)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  project_id                 :bigint
#  provenance_id              :bigint
#  version                    :datetime
#  source_privacy             :integer          default(0)
#
FactoryBot.define do
  factory :data_management_plan do
    title                       { Faker::Movies::StarWars.wookiee_sentence }
    description                 { Faker::Lorem.paragraph }
    ethical_issues              { [nil, true, false].sample }
    ethical_issues_description  { Faker::Lorem.paragraph }
    ethical_issues_report       { Faker::Internet.url }
    language                    { Api::V0::ConversionService::LANGUAGES.sample }
    version                     { Time.now }
    source_privacy              { DataManagementPlan.source_privacies.keys.sample }

    before :create do |data_management_plan|
      data_management_plan.provenance = build(:provenance) unless data_management_plan.provenance.present?
    end

    trait :complete do
      transient do
        contributors_count { 1 }
        datasets_count     { 1 }
        costs_count        { 1 }
        identifiers_count  { 1 }
      end

      after :create do |data_management_plan, evaluator|
        # Ensure there is a primary contact!
        data_management_plan.primary_contact = create(:contributor, :complete) unless data_management_plan.primary_contact.present?
        data_management_plan.project = create(:project, :complete, data_management_plan_count: 0) unless data_management_plan.project.present?

        # Add the DOI
        data_management_plan.identifiers << create(:identifier, category: %w[doi ark].sample,
                                                                identifiable: data_management_plan,
                                                                descriptor: 'is_identified_by',
                                                                value: SecureRandom.uuid,
                                                                provenance: data_management_plan.provenance)

        # URL of the original DMP source
        data_management_plan.identifiers << create(:identifier, category: 'url',
                                                                identifiable: data_management_plan,
                                                                descriptor: 'is_metadata_for',
                                                                value: Faker::Internet.url,
                                                                provenance: data_management_plan.provenance)

        # Add contributors
        evaluator.contributors_count.times do
          per = create(:contributor, :complete, provenance: data_management_plan.provenance)
          j = create(:contributors_data_management_plan, contributor: per, data_management_plan: data_management_plan,
                                                         role: ContributorsDataManagementPlan.roles.keys.sample,
                                                         provenance: data_management_plan.provenance)
          data_management_plan.contributors_data_management_plans << j
        end
        evaluator.costs_count.times do
          data_management_plan.costs << create(:cost, provenance: data_management_plan.provenance)
        end
        evaluator.datasets_count.times do
          data_management_plan.datasets << create(:dataset, :complete, provenance: data_management_plan.provenance)
        end

        relateds = ::Identifier.descriptors.keys.reject { |k| %w[is_identified_by is_metadata_for].include?(k) }
        evaluator.identifiers_count.times do
          data_management_plan.identifiers << create(:identifier, category: ::Identifier.categories.keys.sample,
                                                                  identifiable: data_management_plan,
                                                                  descriptor: relateds.sample,
                                                                  provenance: data_management_plan.provenance)
        end
      end
    end
  end
end
