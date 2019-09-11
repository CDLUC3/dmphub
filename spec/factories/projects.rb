# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    title                 { Faker::Movies::StarWars.wookiee_sentence }
    description           { Faker::Lorem.paragraph }
    start_on              { Time.now + 5.days }
    end_on                { Time.now + 370.days }
  end

  factory :project_with_awards, parent: :project do
    transient do
      award_count { 1 }
    end

    after :create do |project, evaluator|
      evaluator.award_count.times do
        project.awards << create(:award)
      end
    end
  end
end
