# frozen_string_literal: true

FactoryBot.define do
  factory :contributors_data_management_plan do
    role { ContributorsDataManagementPlan.roles.keys.sample }

    before :create do |cdmp|
      cdmp.provenance = build(:provenance) unless cdmp.provenance.present?
    end
  end
end
