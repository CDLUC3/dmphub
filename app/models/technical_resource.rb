# frozen_string_literal: true

# == Schema Information
#
# Table name: technical_resources
#
#  id            :bigint           not null, primary key
#  dataset_id    :bigint
#  description   :text(4294967295)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :string(255)      not null
#  provenance_id :bigint
#
class TechnicalResource < ApplicationRecord
  include Alterable
  include Authorizable

  # Associations
  belongs_to :dataset, optional: true
end
