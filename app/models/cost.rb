# frozen_string_literal: true

# A Data Management Plan Cost
class Cost < ApplicationRecord

  # Associations
  belongs_to :data_management_plan

  # Validations
  validates :title, presence: true

end
