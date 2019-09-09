# frozen_string_literal: true

# A data management plan
class AwardStatus < ApplicationRecord
  enum status: %i[planned applied granted rejected]

  # Associations
  belongs_to :award

  # Validations
  validates :status, :provenance, presence: true

  # Callbacks
  before_validation :ensure_provenance

  # Scopes
  scope :from_json, ->(json, provenance) do
    return nil unless json.present?

    json = delete_base_json_elements(json)
    args = json.select do |k, v|
      !%w[award data_management_plans projects identifiers mbox].include?(k)
    end
    json['provenance'] = provenance || Rails.application.name.downcase unless json['provenance']
    award_status = new(json.select { |k, v| k != 'award' })
    award_status
  end

  private

  def ensure_provenance
    provenance = Rails.application.class.name.underscore unless provenance.present?
  end
end
