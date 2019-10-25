# frozen_string_literal: true

# Oauth Application extended authorization information
class OauthApplicationProfile < ApplicationRecord
  include FlagShihTzu

  serialize :rules, JSON

  # Associations
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application', foreign_key: 'oauth_application_id'

  # Validations
  validates :oauth_application, presence: true

  has_flags 1 => :data_management_plan_creation,
            2 => :award_assertion,
            3 => :person_assertion,
            :column => 'permissions'

  # Retrieve all of the ids of the entities the App has access to
  def authorized_entities(entity_clazz:)
    json = JSON.parse(rules)

    # Determine if the requested entity is authorized for the app
    perms = json.keys.select do |k|
      clazz_name = permission_to_entity_name(permission: k)
      clazz_name == entity_clazz.name && send("#{k}?")
    end
    return [] if perms.empty?

p "PERMITTED? #{send("#{perms.first}?")}"
p json[perms.first]

    ActiveRecord::Base.connection.execute(json[perms.first].to_s)
  end

  private

  def permission_to_entity_name(permission:)
    permission.gsub('_creation', '').gsub('_assertion', '').camelcase
  end
end
