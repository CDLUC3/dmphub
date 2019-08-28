# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    name        { Faker::Movies::StarWars.character }
  end

  factory :person_with_identifier, parent: :person do
    before :create do |person|
      create :identifier, 1, person: person, category: 'email'
    end
  end
end
