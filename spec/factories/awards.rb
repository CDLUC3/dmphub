# frozen_string_literal: true

FactoryBot.define do
  factory :award do
    project
    funder_uri { Faker::Internet.url }

    after :create do |award|
      create(:award_status, award: award)
    end
  end
end
