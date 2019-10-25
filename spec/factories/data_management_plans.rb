# frozen_string_literal: true

FactoryBot.define do
  factory :data_management_plan do
    transient do
      doorkeeper_application { create(:doorkeeper_application) }
    end

    title                       { Faker::Movies::StarWars.wookiee_sentence }
    description                 { Faker::Lorem.paragraph }
    ethical_issues              { [nil, true, false].sample }
    ethical_issues_description  { Faker::Lorem.paragraph }
    ethical_issues_report       { Faker::Internet.url }
    language                    { %w[en fr de es].sample }

    after :create do |dmp, opts|
      create(:oauth_authorization, data_management_plan: dmp, oauth_application: opts.doorkeeper_application)
    end

    trait :complete do
      transient do
        persons_count     { 1 }
        datasets_count    { 1 }
        costs_count       { 1 }
        identifiers_count { 1 }
      end

      after :create do |data_management_plan, evaluator|
        # Ensure there is a primary contact!

        contact = create(:person, :complete)
        pdmp = create(:person_data_management_plan, person: contact,
                                                    data_management_plan: data_management_plan, role: 'primary_contact')
        data_management_plan.person_data_management_plans << pdmp

        evaluator.persons_count.times do
          per = create(:person, :complete)
          j = create(:person_data_management_plan, person: per, data_management_plan: data_management_plan,
                                                   role: %w[author principal_investigator data_librarian].sample)
          data_management_plan.person_data_management_plans << j
        end
        evaluator.costs_count.times do
          data_management_plan.costs << create(:cost)
        end
        evaluator.datasets_count.times do
          data_management_plan.datasets << create(:dataset, :complete)
        end
        evaluator.identifiers_count.times do
          data_management_plan.identifiers << create(:identifier, category: 'doi',
                                                                  identifiable: data_management_plan,
                                                                  descriptor: Identifier.descriptors.keys.sample)
        end
      end
    end
  end
end
