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
    def from_json(json:, provenance:, data_management_plan: nil)
      return nil unless json.present? && provenance.present? && json['title'].present?

      json = json.with_indifferent_access
      cost = find_or_initialize_by(
        data_management_plan: data_management_plan,
        title: json['title']
      )
      cost.description = json['description']
      cost.value = json['value']
      cost.currency_code = json['currency_code']
      cost
    end
  end
end
