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

  accepts_nested_attributes_for :identifiers, :affiliation

  # validates :affiliation, :status, presence: true

  before_validation :ensure_status

  def funded?
    granted? && urls.any?
  end

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    super.copy!(affiliation.errors) if affiliation.present?
    super
  end

  private

  # Ensure defaults
  def ensure_status
    self.status = 'planned' unless status.present?
  end
end
