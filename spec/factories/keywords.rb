# frozen_string_literal: true

# == Schema Information
#
# Table name: keywords
#
#  id         :bigint           not null, primary key
#  value      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :keyword do |_award|
    value { Faker::Lorem.unique.word }
  end
end
