# frozen_string_literal: true

# A data management plan
class DataManagementPlan < ApplicationRecord
  include Describable
  include Identifiable

  # Associations
  belongs_to :project
  has_many :person_data_management_plans
  has_many :persons, through: :person_data_management_plans
  has_many :datasets

  # Validations
  validates :title, :ethical_issues, :language, presence: true
  validates :datasets, length: { minimum: 1 }
end
