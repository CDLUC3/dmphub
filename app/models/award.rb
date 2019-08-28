# frozen_string_literal: true

# A data management plan
class Award < ApplicationRecord

  include Identifiable

  # Associations
  belongs_to :project
  has_many :award_statuses

  # Validations
  validates :funder_uri, presence: true
end
