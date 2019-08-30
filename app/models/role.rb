# frozen_string_literal: true

# Respresents an authorization level
class Role < ApplicationRecord
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  enum name: %i[admin superadmin]
end