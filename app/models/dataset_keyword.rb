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
class DatasetKeyword < ApplicationRecord
  include Alterable

  self.table_name = 'datasets_keywords'

  # Associations
  belongs_to :dataset
  belongs_to :keyword

  # Validations
  validates :dataset, :keyword, presence: true
end
