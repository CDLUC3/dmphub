# frozen_string_literal: true

# A Dataset Metadata
class Metadatum < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Associations
  belongs_to :dataset, optional: true

  # Validations
  validates :language, presence: true
end
