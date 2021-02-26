# frozen_string_literal: true

# == Schema Information
#
# Table name: api_client_authorizations
#
#  id                :bigint           not null, primary key
#  api_client_id     :bigint           not null
#  authorizable_id   :integer          not null
#  authorizable_type :string(255)      default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
FactoryBot.define do
  factory :api_client_authorization do
    trait :for_data_management_plan do
      association :authorizable, factory: :data_management_plan
    end
    trait :for_project do
      association :authorizable, factory: :project
    end
  end
end
