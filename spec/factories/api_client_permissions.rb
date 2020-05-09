# frozen_string_literal: true

FactoryBot.define do
  factory :api_client_permission do
    permissions { [1, 2, 6, 7].sample }
    rules { '{}' }
  end
end
