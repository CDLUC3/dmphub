# frozen_string_literal: true

FactoryBot.define do
  factory :api_client_permission do
    permission { ApiClientPermission.permissions.keys.map(&:to_s).sample }
  end
end
