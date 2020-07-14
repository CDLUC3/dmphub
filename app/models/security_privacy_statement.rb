# frozen_string_literal: true

# A Dataset Security and Privacy Statement
class SecurityPrivacyStatement < ApplicationRecord
  include Alterable
  include Authorizable

  # Associations
  belongs_to :dataset, optional: true

  # Validations
  validates :title, presence: true
end
