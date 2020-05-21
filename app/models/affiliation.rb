# frozen_string_literal: true

# An Organization
class Affiliation < ApplicationRecord
  include Authorizable
  include Identifiable

  serialize :alternate_names
  serialize :attrs
  serialize :types

  # Associations
  has_many :contributors

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_validation :ensure_defaults

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    super
  end

  # Scopes
  class << self
    def funders
      joins(:identifiers).includes(:identifiers)
                         .where(identifiers: { category: 'doi' })
    end
  end

  private

  def ensure_defaults
    self.attrs = {} unless attrs.present?
    self.types = [] unless types.present?
    self.alternate_names = [] unless alternate_names.present?
  end
end
