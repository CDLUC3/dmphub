# frozen_string_literal: true

# A Dataset Metadata
class Metadatum < ApplicationRecord

  include Identifiable

  # Associations
  belongs_to :dataset

  # Validations
  validates :language, presence: true
end
