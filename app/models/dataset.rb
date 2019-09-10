# frozen_string_literal: true

# A dataset
class Dataset < ApplicationRecord

  include Identifiable

  enum dataset_type: %i[dataset software]

  # Associations
  belongs_to :data_management_plan
  has_many :dataset_keywords
  has_many :keywords, through: :dataset_keywords
  has_many :security_privacy_statements
  has_many :technical_resources
  has_many :metadata
  has_many :distributions

  # Validations
  validates :title, :dataset_type, presence: true
end
