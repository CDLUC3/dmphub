# frozen_string_literal: true

# == Schema Information
#
# Table name: keywords
#
#  id         :bigint           not null, primary key
#  value      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Keyword < ApplicationRecord
  # Associations
  has_many :dataset_keywords, dependent: :destroy
  has_many :datasets, through: :dataset_keywords

  # Validations
  validates :value, presence: true, uniqueness: { case_sensitive: false }
end
