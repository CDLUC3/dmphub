# frozen_string_literal: true

# A Data Management Plan Cost
class Cost < ApplicationRecord
  include Alterable
  include Authorizable

  # Associations
  belongs_to :data_management_plan, optional: true

  # Validations
  validates :title, presence: true
end
