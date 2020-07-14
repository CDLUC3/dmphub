# frozen_string_literal: true

# A Data Management Plan to Person Relationship
class ContributorsDataManagementPlan < ApplicationRecord
  include Alterable

  self.table_name = 'contributors_data_management_plans'

  enum role: %i[primary_contact curator author principal_investigator investigator
                data_librarian creator program_officer]

  # Associations
  belongs_to :data_management_plan
  belongs_to :contributor

  accepts_nested_attributes_for :contributor

  # Validations
  validates :role, presence: true
  validates :contributor, uniqueness: { scope: %i[data_management_plan role] }
end
