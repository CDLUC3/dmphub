# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name          { Faker::Name.first_name }
    last_name           { Faker::Name.last_name }
    email               { Faker::Internet.unique.safe_email }
    password            { 'password' }
    accept_terms        { true }
    role                { create(:role) }
    secret              { Faker::Crypto.sha256 }
  end
end
