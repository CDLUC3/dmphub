# frozen_string_literal: true

# Represents an identifier (e.g. ORCID, email, DOI, etc.)
class Identifier < ApplicationRecord
  enum category: %i[ark doi grid orcid ror url]

  # Associations
  belongs_to :identifiable, polymorphic: true

  # Validations
  validates :category, :value, :provenance, presence: true
  validates :value, uniqueness: { scope: %i[category provenance], case_sensitive: false }

  # Callbacks
  before_validation :ensure_provenance

  # Scopes
  scope :from_json, ->(json) do
    return nil unless json.present?

    json = delete_base_json_elements(json)
    new(json)
  end

  private

  def ensure_provenance
    provenance = Rails.application.class.name.underscore unless provenance.present?
  end
end
