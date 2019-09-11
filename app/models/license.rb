# frozen_string_literal: true

# A Dataset Distribution License
class License < ApplicationRecord

  # Associations
  belongs_to :distribution

  # Validations
  validates :license_uri, :start_date, presence: true
end
