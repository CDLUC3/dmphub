# frozen_string_literal: true

# == Schema Information
#
# Table name: affiliations
#
#  id              :bigint           not null, primary key
#  name            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  alternate_names :text(65535)
#  attrs           :json             not null
#  types           :text(65535)
#  provenance_id   :bigint
#
class Affiliation < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  serialize :alternate_names
  serialize :attrs
  serialize :types

  # Associations
  has_many :contributors

  has_and_belongs_to_many :fundings, class_name: 'Funding', join_table: 'fundings_affiliations'

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_validation :ensure_defaults

  # Scopes
  scope :search, lambda { |term:|
    left_outer_joins(:identifiers)
      .where('name LIKE ? OR alternate_names LIKE ?', "%#{term}%", "%#{term}%")
      .distinct
      .order(:name)
  }

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
