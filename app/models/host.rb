# frozen_string_literal: true

# A Dataset Distribution Host
class Host < ApplicationRecord

  include Identifiable

  # Associations
  belongs_to :distribution

  # Validations
  validates :title, presence: true
end
