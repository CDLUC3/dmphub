# frozen_string_literal: true

# A Dataset Security and Privacy Statement
class SecurityPrivacyStatement < ApplicationRecord

  # Associations
  belongs_to :dataset

  # Validations
  validates :title, presence: true
end
