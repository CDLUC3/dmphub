# frozen_string_literal: true

# A data management plan
class DataManagementPlan < ApplicationRecord

  include Identifiable

  # Associations
  belongs_to :oauth_authorization, foreign_key: 'id', optional: true
  belongs_to :project

  has_many :person_data_management_plans
  has_many :persons, through: :person_data_management_plans
  has_many :costs
  has_many :datasets

  # Validations
  validates :title, :language, presence: true

  # Callbacks
  after_create :ensure_dataset!

  # Scopes
  scope :by_client, ->(client_id:) do
    joins(oauth_authorization: :oauth_application).where('oauth_applications.uid = ?', client_id)
  end

  def primary_contact
    PersonDataManagementPlan.where(data_management_plan_id: id, role: 'primary_contact').first
  end

  def persons
    PersonDataManagementPlan.where(data_management_plan_id: id).where.not(role: 'primary_contact')
  end

  private

  def ensure_dataset!
    datasets << Dataset.new(title: title)
    save!
  end
end
