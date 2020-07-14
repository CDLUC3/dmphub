# frozen_string_literal: true

# An external system
class Provenance < ApplicationRecord
  # Associations
  has_many :alterations, class_name: 'ProvenanceAlteration'

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Force lower case
  def name=(val)
    super(val.present? ? val.to_s.downcase.gsub(/\s/, '_') : val)
  end
end
