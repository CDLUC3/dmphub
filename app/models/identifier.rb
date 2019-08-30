# frozen_string_literal: true

# Represents an identifier (e.g. ORCID, email, DOI, etc.)
class Identifier < ApplicationRecord
  enum category: %i[email orcid doi ark url]

  # Associations
  belongs_to :identifiable, polymorphic: true

  # Validations
  validates :category, :value, presence: true
  validates :value, uniqueness: { scope: :category, case_sensitive: false }
end
