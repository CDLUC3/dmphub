# frozen_string_literal: true

# A Data Management Plan Cost
class Cost < ApplicationRecord

  # Associations
  belongs_to :data_management_plan, optional: true

  # Validations
  validates :title, presence: true

  # Callbacks
  before_create :creatable?

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? && json['title'].present?

      json = json.with_indifferent_access
      new(title: json['title'], description: json['description'],
          value: json['value'], currency_code: json['currency_code'])
    end

  end

  # Instance Methods

  private

  # Will cancel a create if the record already exists
  def creatable?
    #return false if Cost.where(title: title,
    #  data_management_plan_id: data_management_plan_id).any?
    #true
  end
end
