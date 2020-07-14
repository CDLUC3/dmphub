# frozen_string_literal: true

# A Dataset Distribution
class Distribution < ApplicationRecord
  include Alterable
  include Authorizable

  enum data_access: %i[closed open shared]

  # Associations
  belongs_to :dataset, optional: true
  has_one :host, dependent: :destroy
  has_many :licenses, dependent: :destroy

  # Validations
  validates :title, presence: true
end
