# frozen_string_literal: true

# A dataset
class Dataset < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Based on the DataCite 4.3 schema resourceTypeGeneral
  # Note that the 'model' value is changed to 'model_type' in this list
  # because 'model' conflicts with an ActiveRecord method
  enum dataset_type: %i[audiovisual collection datapaper dataset event image
                        interactive_resource model_type other physical_object service
                        software sound text workflow]

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
