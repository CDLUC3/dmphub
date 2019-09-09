# frozen_string_literal: true

# A description
class Description < ApplicationRecord
  enum category: %i[abstract ethical_issue preservation_statement quality_assurance]

  # Associations
  belongs_to :describable, polymorphic: true

  # Validations
  validates :category, :value, presence: true
end
