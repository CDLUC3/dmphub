# frozen_string_literal: true

# A data management plan
class DataManagementPlan < ApplicationRecord

  include Describable
  include Identifiable

  # Associations
  belongs_to :project
  has_many :person_data_management_plans
  has_many :persons, through: :person_data_management_plans

  # Validations
  validates :title, :ethical_issues, :language, presence: true
end
