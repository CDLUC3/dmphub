# frozen_string_literal: true

# A dataset
class Dataset < ApplicationRecord
  include Describable
  include Identifiable

  enum dataset_type: %i[dataset software]

  # Associations
  belongs_to :data_management_plan

  # Validations
  validates :title, :dataset_type, presence: true
end
