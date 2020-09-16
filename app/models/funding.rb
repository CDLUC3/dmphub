# frozen_string_literal: true

# A data management plan
class Funding < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  enum status: %i[planned applied granted rejected]

  # Associations
  belongs_to :project, optional: true
  belongs_to :affiliation

  has_and_belongs_to_many :funded_affiliations, class_name: 'Affiliation', join_table: 'fundings_affiliations'

  accepts_nested_attributes_for :identifiers, :affiliation, :funded_affiliations

  # validates :affiliation, :status, presence: true

  before_validation :ensure_status

  def funded?
    granted? && urls.any?
  end

  private

  # Ensure defaults
  def ensure_status
    self.status = 'planned' unless status.present?
  end
end
