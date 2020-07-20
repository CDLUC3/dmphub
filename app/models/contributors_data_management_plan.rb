# frozen_string_literal: true

# A Data Management Plan to Person Relationship
class ContributorsDataManagementPlan < ApplicationRecord
  include Alterable

  self.table_name = 'contributors_data_management_plans'

  enum role: %i[
    primary_contact
    https://dictionary.casrai.org/Contributor_Roles/Conceptualization
    https://dictionary.casrai.org/Contributor_Roles/Data_curation
    https://dictionary.casrai.org/Contributor_Roles/Formal_analysis
    https://dictionary.casrai.org/Contributor_Roles/Funding_acquisition
    https://dictionary.casrai.org/Contributor_Roles/Investigation
    https://dictionary.casrai.org/Contributor_Roles/Methodology
    https://dictionary.casrai.org/Contributor_Roles/Project_administration
    https://dictionary.casrai.org/Contributor_Roles/Resources
    https://dictionary.casrai.org/Contributor_Roles/Software
    https://dictionary.casrai.org/Contributor_Roles/Supervision
    https://dictionary.casrai.org/Contributor_Roles/Validation
    https://dictionary.casrai.org/Contributor_Roles/Visualization
    https://dictionary.casrai.org/Contributor_Roles/Writing_original_draft
    https://dictionary.casrai.org/Contributor_Roles/Writing_review_Editing
  ]

  # Associations
  belongs_to :data_management_plan
  belongs_to :contributor

  accepts_nested_attributes_for :contributor

  # Validations
  validates :role, presence: true
  validates :contributor, uniqueness: { scope: %i[data_management_plan role] }
end
