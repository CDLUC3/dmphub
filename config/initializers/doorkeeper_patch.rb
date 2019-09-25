# frozen_string_literal: true

require 'doorkeeper/orm/active_record/application'

Rails.logger.info 'Extending Doorkeeper::Application from config/initializers/doorkeeper_patch.rb'

# Monkey patch to Doorkeeper::Application to connect a client application
# to the Data Management Plans that it owns
Doorkeeper::Application.class_eval do
  has_many :oauth_authorizations, foreign_key: 'oauth_application_id'
  has_many :data_management_plans, through: :oauth_authorizations
end
