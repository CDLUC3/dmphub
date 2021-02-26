# frozen_string_literal: true

# == Schema Information
#
# Table name: datasets
#
#  id                      :bigint           not null, primary key
#  data_management_plan_id :bigint
#  title                   :string(255)      not null
#  dataset_type            :integer          default("audiovisual"), not null
#  personal_data           :boolean
#  sensitive_data          :boolean
#  description             :text(4294967295)
#  publication_date        :datetime
#  language                :string(255)
#  data_quality_assurance  :text(4294967295)
#  preservation_statement  :text(4294967295)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  provenance_id           :bigint
#
FactoryBot.define do
  factory :dataset do
    title                       { Faker::Movies::StarWars.wookiee_sentence }
    description                 { Faker::Lorem.paragraph }
    dataset_type                { Dataset.dataset_types.keys.sample }
    publication_date            { Time.now.to_s }
    language                    { %w[en es de fr].sample }
    sensitive_data              { [nil, true, false].sample }
    personal_data               { [nil, true, false].sample }
    data_quality_assurance      { Faker::Lorem.paragraph }
    preservation_statement      { Faker::Lorem.paragraph }

    before :create do |dataset|
      dataset.provenance = build(:provenance) unless dataset.provenance.present?
    end

    trait :complete do
      transient do
        identifier_count                  { 1 }
        keyword_count                     { 1 }
        technical_resource_count          { 1 }
        security_privacy_statement_count  { 1 }
        metadatum_count                   { 1 }
        distribution_count                { 1 }
      end

      after :create do |dataset, evaluator|
        evaluator.identifier_count.times do
          dataset.identifiers << create(:identifier, category: 'url', identifiable: dataset,
                                                     descriptor: Identifier.descriptors.keys.sample,
                                                     provenance: dataset.provenance)
        end
        # evaluator.keyword_count.times do
        #   dataset.keywords << create(:keyword)
        # end
        evaluator.technical_resource_count.times do
          dataset.technical_resources << create(:technical_resource, provenance: dataset.provenance)
        end
        evaluator.security_privacy_statement_count.times do
          dataset.security_privacy_statements << create(:security_privacy_statement, provenance: dataset.provenance)
        end
        evaluator.metadatum_count.times do
          dataset.metadata << create(:metadatum, :complete, provenance: dataset.provenance)
        end
        evaluator.distribution_count.times do
          dataset.distributions << create(:distribution, :complete, provenance: dataset.provenance)
        end
      end
    end
  end
end
