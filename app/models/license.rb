# frozen_string_literal: true

# A Dataset Distribution License
class License < ApplicationRecord
  include Alterable
  include Authorizable

  # Associations
  belongs_to :distribution, optional: true

  # Validations
  validates :license_ref, :start_date, presence: true
end
