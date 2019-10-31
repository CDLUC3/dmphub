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
    def from_json!(provenance:, json:, data_management_plan:)
      return nil unless json.present? && provenance.present? && data_management_plan.present?

      json = json.with_indifferent_access
      return nil unless json['title'].present? &&
            (json['description'].present? || json['value'].present?)

      cost = Cost.find_or_initialize_by(data_management_plan: data_management_plan, title: json['title'])

      cost.description = json['description'] if json['description'].present?
      cost.value = json['value'] if json['value'].present?
      cost.currency_code = json.fetch('currencyCode', (cost.value.present? ? 'usd' : nil))
      cost.save
      cost
    end
  end
end
