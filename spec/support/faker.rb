# frozen_string_literal: true

require 'faker'

RSpec.configure do |config|
  config.after(:each) do
    Faker::Name.unique.clear
    Faker::Alphanumeric.unique.clear
    Faker::UniqueGenerator.clear
  end
end
