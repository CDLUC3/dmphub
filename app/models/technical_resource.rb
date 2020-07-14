# frozen_string_literal: true

# A Dataset Technical Resource
class TechnicalResource < ApplicationRecord
  include Alterable
  include Authorizable

  # Associations
  belongs_to :dataset, optional: true
end
