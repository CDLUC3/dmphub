# frozen_string_literal: true

# == Schema Information
#
# Table name: security_privacy_statements
#
#  id            :bigint           not null, primary key
#  dataset_id    :bigint
#  title         :string(255)      not null
#  description   :text(4294967295)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provenance_id :bigint
#
# A Dataset Security and Privacy Statement
class SecurityPrivacyStatement < ApplicationRecord
  include Alterable
  include Authorizable

  # Associations
  belongs_to :dataset, optional: true

  # Validations
  validates :title, presence: true
end
