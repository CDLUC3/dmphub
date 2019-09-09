# frozen_string_literal: true

FactoryBot.define do
  factory :data_management_plan do
    transient do
      doorkeeper_application { create(:doorkeeper_application) }
    end

    project                 { create(:project) }
    title                   { Faker::Movies::StarWars.wookiee_sentence }
    ethical_issues          { [0, 1, 2].sample }
    language                { 'en' }

    after :create do |dmp, opts|
      create(:oauth_authorization, data_management_plan: dmp, oauth_application: opts.doorkeeper_application)
    end

    trait :complete do
      after :create do |dmp, opts|
        2.times { create(:person_data_management_plan, data_management_plan: dmp, role: 'author') }
        create(:person_data_management_plan, data_management_plan: dmp, role: 'primary_contact')
        dmp.descriptions << create(:data_management_plan_description)
        2.times { dmp.identifiers << create(:data_management_plan_identifier) }
        dmp.project = create(:project_with_awards)
        dmp.datasets << create(:dataset, :complete)
        dmp.save
      end
    end
  end
end
