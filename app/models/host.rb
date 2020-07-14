# frozen_string_literal: true

# A Dataset Distribution Host
class Host < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Associations
  belongs_to :distribution, optional: true

  # Validations
  validates :title, presence: true
end
