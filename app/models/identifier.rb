# frozen_string_literal: true

# Represents an identifier (e.g. ORCID, email, DOI, etc.)
class Identifier < ApplicationRecord
  enum category: %i[email orcid doi ark url]

  # Associations
  belongs_to :identifiable, polymorphic: true

  # Validations
  validates :category, :value, :provenance, presence: true
  validates :value, uniqueness: { scope: %i[category provenance], case_sensitive: false }

  # Callbacks
  before_validation :ensure_provenance

  private

  def ensure_provenance
    provenance = Rails.application.class.name.underscore unless provenance.present?
  end
end
