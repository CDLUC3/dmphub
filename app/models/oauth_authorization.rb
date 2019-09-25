# frozen_string_literal: true

# Oauth Application to Data Management Plan Relationship
class OauthAuthorization < ApplicationRecord
  # Associations
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application', foreign_key: 'oauth_application_id'
  belongs_to :data_management_plan

  # Validations
  validates :oauth_application, :data_management_plan, presence: true
end
