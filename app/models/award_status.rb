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

  def to_json(options = [])
    super((%i[status provenance no_hateoas] + options).uniq)
  end

  private

  def ensure_provenance
    provenance = Rails.application.class.name.underscore unless provenance.present?
  end
end
