# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    title                 { Faker::Movies::StarWars.wookiee_sentence }
    data_management_plans {}
  end

  factory :project_with_awards, parent: :project do
    sequence(:awards)     { |_n| create(:award) }
  end
end
