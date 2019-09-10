# frozen_string_literal: true

FactoryBot.define do
  factory :award do |award|
    project
    funder_uri { Faker::Internet.url }
    status     { Award.statuses.keys.sample }
  end
end
