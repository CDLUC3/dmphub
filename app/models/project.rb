# frozen_string_literal: true

# A project
class Project < ApplicationRecord

  include Describable

  # Associations
  has_many :data_management_plans
  has_many :awards

  # Validations
  validates :title, presence: true
end
