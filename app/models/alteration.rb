# frozen_string_literal: true

# An external system
class Alteration < ApplicationRecord
  # Associations
  belongs_to :provenance
  belongs_to :alterable, polymorphic: true

  # Validations
  validates :provenance, :alterable, presence: true
end
