# frozen_string_literal: true

FactoryBot.define do
  factory :api_client_history do
    type { ApiClientHistory.types.sample }
    description { Faker::Lorem.sentence }
  end
end
