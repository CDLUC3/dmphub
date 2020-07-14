# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name          { Faker::Name.first_name }
    last_name           { Faker::Name.last_name }
    email               { Faker::Internet.unique.safe_email }
    password            { 'password' }
    accept_terms        { true }
    role                { 'user' }
    secret              { Faker::Crypto.sha256 }

    trait :complete do
      after :create do |user|
        user.affiliation = create(:affiliation) unless user.affiliation.present?
      end
    end
  end
end
