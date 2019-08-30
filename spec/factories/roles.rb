# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name    { Role.names.keys.sample }

    trait :super_admin do
      name  { 'superadmin' }
    end
    trait :admin do
      name  { 'admin' }
    end
  end
end
