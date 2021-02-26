# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id            :bigint           not null, primary key
#  title         :string(255)      not null
#  start_on      :datetime
#  end_on        :datetime
#  description   :text(4294967295)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provenance_id :bigint
#
FactoryBot.define do
  factory :project do
    title                 { Faker::Movies::StarWars.wookiee_sentence }
    description           { Faker::Lorem.paragraph }
    start_on              { Time.now + 5.days }
    end_on                { Time.now + 370.days }

    before :create do |project|
      project.provenance = build(:provenance) unless project.provenance.present?
    end

    trait :complete do
      transient do
        funding_count { 1 }
        data_management_plan_count { 1 }
      end

      after :create do |project, evaluator|
        evaluator.funding_count.times do
          project.fundings << create(:funding, :complete, provenance: project.provenance)
        end
        evaluator.data_management_plan_count.times do
          project.data_management_plans << create(:data_management_plan, :complete, provenance: project.provenance)
        end
      end
    end
  end
end
