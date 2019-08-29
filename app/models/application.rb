# frozen_string_literal: true

# Represents an application that uses our API
class Application < ApplicationRecord
  enum category: %i[dmp_provider]

  # Associations
  has_many :users

  # Validations
  validates :title, :category, presence: true
end
