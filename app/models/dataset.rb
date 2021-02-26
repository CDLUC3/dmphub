# frozen_string_literal: true

# == Schema Information
#
# Table name: datasets
#
#  id                      :bigint           not null, primary key
#  data_management_plan_id :bigint
#  title                   :string(255)      not null
#  dataset_type            :integer          default("audiovisual"), not null
#  personal_data           :boolean
#  sensitive_data          :boolean
#  description             :text(4294967295)
#  publication_date        :datetime
#  language                :string(255)
#  data_quality_assurance  :text(4294967295)
#  preservation_statement  :text(4294967295)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  provenance_id           :bigint
#
# A dataset
class Dataset < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Based on the DataCite 4.3 schema resourceTypeGeneral
  # Note that the 'model' value is changed to 'model_representation' in this list
  # because 'model' conflicts with an ActiveRecord method
  enum dataset_type: %i[audiovisual collection datapaper dataset event image
                        interactive_resource model_representation other physical_object
                        service software sound text workflow]

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
