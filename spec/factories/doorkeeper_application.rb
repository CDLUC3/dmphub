# frozen_string_literal: true

FactoryBot.define do
  factory :doorkeeper_application, class: Doorkeeper::Application do
    name          { Faker::Company.unique.name }
    redirect_uri  { 'urn:ietf:wg:oauth:2.0:oob' }
  end
end
