# frozen_string_literal: true

# A Data Management Plan to Person Relationship
class PersonDataManagementPlan < ApplicationRecord
  self.table_name = 'persons_data_management_plans'

  enum role: %i[primary_contact curator author principal_investigator investigator
                data_librarian creator program_officer]

  # Associations
  belongs_to :data_management_plan
  belongs_to :person

  accepts_nested_attributes_for :person

  # Validations
  validates :role, presence: true
  validates :person, uniqueness: { scope: %i[data_management_plan role] }
end
