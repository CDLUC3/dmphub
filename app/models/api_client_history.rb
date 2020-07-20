# frozen_string_literal: true

# An event that the ApiClient performed on a DataManagementPlan
class ApiClientHistory < ApplicationRecord
  # ============ #
  # Associations #
  # ============ #

  belongs_to :api_client
  belongs_to :data_management_plan

  # ===============
  # = Validations =
  # ===============

  validates :description, presence: true

  enum change_type: %i[add edit archive embargo]
end
