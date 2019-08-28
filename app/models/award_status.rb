# frozen_string_literal: true

# A data management plan
class AwardStatus < ApplicationRecord

  enum status: %i[planned applied granted rejected]

  # Associations
  belongs_to :award

  # Validations
  validates :status, presence: true
end
