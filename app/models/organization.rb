# frozen_string_literal: true

# An Organization
class Organization < ApplicationRecord

  include Identifiable

  # Associations
  has_many :person_organizations
  has_many :persons, through: :person_organizations

  # Validations
  validates :name, presence: true, uniqueness: true

end
