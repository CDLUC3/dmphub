# frozen_string_literal: true

# == Schema Information
#
# Table name: api_client_histories
#
#  id                      :bigint           not null, primary key
#  api_client_id           :bigint           not null
#  data_management_plan_id :bigint           not null
#  change_type             :integer
#  description             :text(65535)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
FactoryBot.define do
  factory :api_client_history do
    type { ApiClientHistory.types.keys.sample }
    description { Faker::Lorem.sentence }
  end
end
