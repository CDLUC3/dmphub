# frozen_string_literal: true

# A Data Management Plan to Person Relationship
class ContributorsDataManagementPlan < ApplicationRecord
  include Alterable

  self.table_name = 'contributors_data_management_plans'

  enum role: %i[
    primary_contact
    http://credit.niso.org/contributor-roles/conceptualization
    http://credit.niso.org/contributor-roles/data-curation
    http://credit.niso.org/contributor-roles/formal-analysis
    http://credit.niso.org/contributor-roles/funding-acquisition
    http://credit.niso.org/contributor-roles/investigation
    http://credit.niso.org/contributor-roles/methodology
    http://credit.niso.org/contributor-roles/project-administration
    http://credit.niso.org/contributor-roles/resources
    http://credit.niso.org/contributor-roles/software
    http://credit.niso.org/contributor-roles/supervision
    http://credit.niso.org/contributor-roles/validation
    http://credit.niso.org/contributor-roles/visualization
    http://credit.niso.org/contributor-roles/writing-original-draft
    http://credit.niso.org/contributor-roles/writing-review-editing
  ]

  # Associations
  belongs_to :data_management_plan
  belongs_to :contributor

  accepts_nested_attributes_for :contributor

  # Validations
  validates :role, presence: true
  validates :contributor, uniqueness: { scope: %i[data_management_plan role] }
end
