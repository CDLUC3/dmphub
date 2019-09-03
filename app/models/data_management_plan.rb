# frozen_string_literal: true

# A data management plan
class DataManagementPlan < ApplicationRecord
  include Describable
  include Identifiable

  # Associations
  belongs_to :oauth_authorization, foreign_key: 'id', optional: true
  belongs_to :project
  has_many :person_data_management_plans
  has_many :persons, through: :person_data_management_plans
  has_many :datasets

  # Validations
  validates :title, :language, presence: true
  validates :ethical_issues, inclusion: 0..2

  # Callbacks
  after_create :ensure_dataset!

  private

  def ensure_dataset!
    datasets << Dataset.new(title: title)
    save!
  end

end
