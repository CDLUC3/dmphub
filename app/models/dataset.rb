# frozen_string_literal: true

# A dataset
class Dataset < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  enum dataset_type: %i[dataset software http://purl.org/coar/resource_type/c_ddb1]

  # Associations
  belongs_to :data_management_plan, optional: true
  has_many :dataset_keywords, dependent: :destroy
  has_many :keywords, through: :dataset_keywords
  has_many :security_privacy_statements, dependent: :destroy
  has_many :technical_resources, dependent: :destroy
  has_many :metadata, dependent: :destroy
  has_many :distributions, dependent: :destroy

  # Validations
  validates :title, :dataset_type, presence: true
end
