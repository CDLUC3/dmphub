# frozen_string_literal: true

# An external system
class Provenance < ApplicationRecord
  # Associations
  has_many :alterations

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Scopes
  scope :by_api_client, lambda { |api_client:|
    where(name: to_provenance_name(name_in: api_client.name))
  }

  # Force lower case
  def name=(val)
    super(val.present? ? to_provenance_name(name_in: val) : val)
  end

  private

  def to_provenance_name(name_in:)
    self.class.to_provenance_name(name_in: name_in)
  end

  class << self
    def to_provenance_name(name_in:)
      name_in.downcase.gsub(/\s/, '_')
    end
  end
end
