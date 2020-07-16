# frozen_string_literal: true

# A Data Management Plan to Person Relationship
class ContributorsDataManagementPlan < ApplicationRecord
  include Alterable

  self.table_name = 'contributors_data_management_plans'

  enum role: %i[
    primary_contact
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Conceptualization
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Data_Curation
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Formal_Analysis
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Funding_Acquisition
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Investigation
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Methodology
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Project_Administration
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Resources
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Software
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Supervision
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Validation
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Visualization
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Writing_Original_Draft
    https://dictionary.casrai.org/Contributor_Roles/Data_Curation/Writing_Review_&_Editing
  ]

  # Associations
  belongs_to :data_management_plan
  belongs_to :contributor

  accepts_nested_attributes_for :contributor

  # Validations
  validates :role, presence: true
  validates :contributor, uniqueness: { scope: %i[data_management_plan role] }
end
