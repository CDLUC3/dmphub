# frozen_string_literal: true

# A Data Management Plan Cost
class Cost < ApplicationRecord

  # Associations
  belongs_to :data_management_plan, optional: true

  # Validations
  validates :title, presence: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present?
      json = json.with_indifferent_access
      new(title: json.fetch('title', ''), description: json.fetch('description', ''),
          value: json.fetch('value', 0.00), currency_code: json.fetch('currency_code', ''))
    end

  end

end
