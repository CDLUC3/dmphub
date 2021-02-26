# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id              :bigint           not null, primary key
#  distribution_id :bigint
#  license_ref     :string(255)      not null
#  start_date      :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  provenance_id   :bigint
#
# A Dataset Distribution License
class License < ApplicationRecord
  include Alterable
  include Authorizable

  # Associations
  belongs_to :distribution, optional: true

  # Validations
  validates :license_ref, :start_date, presence: true
end
