# frozen_string_literal: true

FactoryBot.define do
  factory :data_management_plan do
    project                 { create(:project) }
    title                   { Faker::Movies::StarWars.wookiee_sentence }
    ethical_issues          { [0, 1, 2].sample }
    language                { 'en' }
    #sequence(:datasets, 1)  { |n| create(:dataset) }
  end
end
