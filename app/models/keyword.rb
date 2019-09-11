# frozen_string_literal: true

# A Dataset Keyword
class Keyword < ApplicationRecord

  # Associations
  has_many :dataset_keywords
  has_many :datasets, through: :dataset_keywords

  # Validations
  validates :value, presence: true
end
