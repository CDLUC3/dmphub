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

  def has_personal_data?
    personal_data == 0 ? 'no' : personal_data == 1 ? 'yes' : 'unknown'
  end

  def has_sensitive_data?
    sensitive_data == 0 ? 'no' : sensitive_data == 1 ? 'yes' : 'unknown'
  end
end
