# frozen_string_literal: true

# A description
class Description < ApplicationRecord
  enum category: %i[description ethical_issue]

  # Associations
  belongs_to :describable, polymorphic: true

  # Validations
  validates :category, :value, presence: true
end
