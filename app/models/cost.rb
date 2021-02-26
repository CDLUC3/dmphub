# frozen_string_literal: true

# == Schema Information
#
# Table name: costs
#
#  id                      :bigint           not null, primary key
#  data_management_plan_id :bigint
#  title                   :string(255)      not null
#  description             :text(4294967295)
#  value                   :float(24)
#  currency_code           :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  provenance_id           :bigint
#
# A Data Management Plan Cost
class Cost < ApplicationRecord
  include Alterable
  include Authorizable

  # Associations
  belongs_to :data_management_plan, optional: true

  # Validations
  validates :title, presence: true
end
