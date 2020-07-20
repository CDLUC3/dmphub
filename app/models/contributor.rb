# frozen_string_literal: true

# A person
class Contributor < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Associations
  has_many :contributors_data_management_plans, dependent: :destroy
  has_many :data_management_plans, through: :contributors_data_management_plans
  has_many :projects, through: :data_management_plans
  belongs_to :affiliation, optional: true

  accepts_nested_attributes_for :identifiers, :affiliation

  # Validations
  validates :name, presence: true
  validates :email, uniqueness: { case_sensitive: false }
end
