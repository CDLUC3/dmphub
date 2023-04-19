# frozen_string_literal: true

# == Schema Information
#
# Table name: metadata
#
#  id            :bigint           not null, primary key
#  dataset_id    :bigint
#  language      :string(255)      not null
#  description   :text(4294967295)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provenance_id :bigint
#
class Metadatum < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Associations
  belongs_to :dataset, optional: true

  # Validations
  validates :language, presence: true

  # The RDA Common standard only allows for the description.
  def name
    description.split(' - ').first
  end
end
