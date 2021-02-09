# frozen_string_literal: true

# A Dataset Distribution
class Distribution < ApplicationRecord
  include Alterable
  include Authorizable

  enum data_access: %i[open embargoed restricted closed]

  # Associations
  belongs_to :dataset, optional: true
  has_one :host
  has_many :licenses, dependent: :destroy

  # Validations
  validates :title, presence: true
end
