# frozen_string_literal: true

# Represents an identifier (e.g. ORCID, email, DOI, etc.)
class Identifier < ApplicationRecord
  include Alterable

  enum category: %i[ark doi credit duns fundref handle isni orcid openid program
                    ror sub_program url]
  enum descriptor: %i[described_by funded_by identified_by is_metadata_for]

  # Associations
  belongs_to :identifiable, polymorphic: true

  # Validations
  validates :category, :value, :provenance, presence: true

  # Categories that need to be universally unique (e.g. DOI, URL or ORCID)
  # Should be unique for the :category
  validates :value, uniqueness: { scope: %i[category], case_sensitive: false },
                    if: proc { |id| requires_universal_uniqueness.include?(id.category) }
  # Other categories (e.g. PROGRAM) should be unique per provenance + identifiable
  validates :value, uniqueness: { scope: %i[category provenance_id identifiable_id],
                                  case_sensitive: false },
                    unless: proc { |id| requires_universal_uniqueness.include?(id.category) }

  # Scopes
  scope :by_provenance_and_category_and_value, lambda { |provenance:, category:, value:|
    ret = where(category: category, value: value)
    ret = ret.where(provenance: provenance) unless requires_universal_uniqueness.include?(category.to_sym)
    ret
  }

  private

  def requires_universal_uniqueness
    ::Identifier.requires_universal_uniqueness
  end

  class << self
    # Categories that REQUIRE that the value is unique regardless of provenance
    # and Identifiable type
    def requires_universal_uniqueness
      %i[ark doi orcid ror fundref url credit]
    end
  end
end
