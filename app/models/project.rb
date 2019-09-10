# frozen_string_literal: true

# A project
class Project < ApplicationRecord

  # Associations
  has_many :data_management_plans
  has_many :awards

  # Validations
  validates :title, :start_on, :end_on, presence: true

end
