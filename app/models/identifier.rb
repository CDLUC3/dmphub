# frozen_string_literal: true

# Represents an identifier (e.g. ORCID, email, DOI, etc.)
class Identifier < ApplicationRecord
  enum category: %i[ark doi grid orcid ror url]
  enum descriptor: %i[identified_by is_metadata_for funded_by described_by]
  # Associations
  belongs_to :identifiable, polymorphic: true

  # Validations
  validates :category, :value, :provenance, presence: true
  validates :value, uniqueness: { scope: %i[category provenance], case_sensitive: false }

  # Callbacks
  before_validation :ensure_provenance

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present?

      json = json.with_indifferent_access
      return nil unless json['value'].present?

      identifier = find_or_initialize_by(
        category: json.fetch('category', 'url'),
        provenance: provenance,
        value: json.fetch('value', '')
      )
      identifier.descriptor = json['descriptor']
      identifier
    end
  end

  private

  def ensure_provenance
    @provenance = Rails.application.class.name.split('::').first.downcase unless @provenance.present?
  end
end
