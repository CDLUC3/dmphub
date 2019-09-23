# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_authorization do
    oauth_application     { create(:doorkeeper_application) }
  end
end
