# frozen_string_literal: true

# A change log
class Alteration < ApplicationRecord
  # Associations
  belongs_to :provenance

  belongs_to :alterable, polymorphic: true

  # validations
  validates :provenance, :alterable, :change_log, presence: true
end
