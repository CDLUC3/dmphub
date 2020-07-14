# frozen_string_literal: true

# A Dataset Keyword
class Keyword < ApplicationRecord
  include Alterable
  
  # Associations
  has_many :dataset_keywords, dependent: :destroy
  has_many :datasets, through: :dataset_keywords

  # Validations
  validates :value, presence: true, uniqueness: { case_sensitive: false }
end
