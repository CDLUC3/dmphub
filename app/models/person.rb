# frozen_string_literal: true

# A person
class Person < ApplicationRecord
  self.table_name = 'persons'

  include Identifiable

  # Associations
  has_many :person_data_management_plans
  has_many :data_management_plans, through: :person_data_management_plans
  has_many :projects, through: :data_management_plans

  # Validations
  validates :name, presence: true
end
