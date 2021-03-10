# frozen_string_literal: true

# == Schema Information
#
# Table name: datasets_keywords
#
#  id         :bigint           not null, primary key
#  dataset_id :bigint
#  keyword_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# The Join Bewteen a Dataset and a Keyword
FactoryBot.define do
  factory :dataset_keyword do
    dataset
    keyword
  end
end
