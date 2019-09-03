# frozen_string_literal: true

FactoryBot.define do
  factory :description do
    category     { Description.categories.keys.sample }
    value        { Faker::Lorem.paragraph }
  end

  factory :data_management_plan_description, parent: :description do |description|
    description.describable { |i| i.association(:data_management_plan) }
  end

  factory :dataset_description, parent: :description do |description|
    description.describable { |i| i.association(:dataset) }
  end

  factory :project_description, parent: :description do |description|
    description.describable { |i| i.association(:project) }
  end
end
