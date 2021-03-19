# frozen_string_literal: true

# == Schema Information
#
# Table name: hosts
#
#  id                  :bigint           not null, primary key
#  title               :string(255)      not null
#  description         :text(4294967295)
#  supports_versioning :boolean
#  backup_type         :string(255)
#  backup_frequency    :string(255)
#  storage_type        :string(255)
#  availability        :string(255)
#  geo_location        :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  certified_with      :text(65535)
#  pid_system          :text(65535)
#  provenance_id       :bigint
#
class Host < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Associations
  has_many :distributions

  # Validations
  validates :title, presence: true
end
