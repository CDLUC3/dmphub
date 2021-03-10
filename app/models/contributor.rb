# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors
#
#  id             :bigint           not null, primary key
#  name           :string(255)      not null
#  email          :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  affiliation_id :bigint
#  provenance_id  :bigint
#
# A person
class Contributor < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Associations
  has_many :contributors_data_management_plans, dependent: :destroy
  has_many :data_management_plans, through: :contributors_data_management_plans
  has_many :projects, through: :data_management_plans
  belongs_to :affiliation, optional: true

  accepts_nested_attributes_for :identifiers, :affiliation

  # Validations
  validates :name, presence: true
  validates :email, uniqueness: { case_sensitive: false, allow_nil: true, allow_blank: true }

  # Instance Methods
  def name_first_last
    name.split.reverse.join(' ')
  end
end
