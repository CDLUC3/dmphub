# frozen_string_literal: true

# A data management plan
class PersonDataManagementPlan < ApplicationRecord

  self.table_name = 'persons_data_management_plans'

  enum role: %i[primary_contact curator author]

  # Associations
  belongs_to :data_management_plan
  belongs_to :person

  # Validations
  validates :role, presence: true
end
