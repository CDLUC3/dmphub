# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsors
#
#  id                       :bigint           not null, primary key
#  name                     :string(255)      not null
#  name_type                :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  data_management_plan_id  :bigint           not null
#  provenance_id            :bigint
#
class Sponsor < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Callbacks
  before_validation :ensure_name_type

  # Associations
  belongs_to :data_management_plan

  # Validations
  validates :name, presence: true
  validates :name_type, presence: true

  enum name_types: %i[organizational personal]

  private

  def ensure_name_type
    self.name_type = 'organizational' unless name_type.present?
  end
end
