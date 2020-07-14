# frozen_string_literal: true

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
