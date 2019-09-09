# frozen_string_literal: true

# A description
class Description < ApplicationRecord
  enum category: %i[abstract ethical_issue preservation_statement quality_assurance]

  # Associations
  belongs_to :describable, polymorphic: true

  # Validations
  validates :category, :value, presence: true

  # Scopes
  scope :from_json, ->(json) do
    return nil unless json.present?

    json = delete_base_json_elements(json)
    new(json)
  end
end
