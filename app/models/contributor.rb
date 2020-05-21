# frozen_string_literal: true

# A person
class Contributor < ApplicationRecord
  include Authorizable
  include Identifiable

  serialize :roles

  # Associations
  has_many :contributors_data_management_plans, dependent: :destroy
  has_many :data_management_plans, through: :contributors_data_management_plans
  has_many :projects, through: :data_management_plans
  belongs_to :affiliation, optional: true

  accepts_nested_attributes_for :identifiers, :affiliation

  # Validations
  validates :name, presence: true
  validates :email, uniqueness: { case_sensitive: false }

  # Callbacks
  before_validation :ensure_roles

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    super.copy!(affiliation.errors) if affiliation.present?
    super
  end

  private

  def ensure_roles
    self.roles = [] unless roles.present?
  end
end
