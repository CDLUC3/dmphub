# frozen_string_literal: true

# A Dataset Distribution
class Distribution < ApplicationRecord

  enum data_access: %i[closed open shared]

  # Associations
  belongs_to :dataset
  has_many :hosts
  has_many :licenses

  # Validations
  validates :title, presence: true


end
