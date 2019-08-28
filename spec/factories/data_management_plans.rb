# frozen_string_literal: true

FactoryBot.define do
  factory :data_management_plan do
    contact         { create(:person) }
    title           { Faker::Movies::StarWars.wookiee_sentence }
    language        { 'en' }
    ethical_issues  { %i[0 1 2].sample }
  end
end
