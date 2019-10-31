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
    return [] unless entity_clazz.present?

    case entity_clazz.name
    when 'DataManagementPlan'
      OauthAuthorization.where(oauth_application: oauth_application)
                        .pluck(:data_management_plan_id)
    when 'User'
      User.data_management_plans.pluck(:id)
    else
      authorization_by_rules(entity_clazz: entity_clazz)
    end
  end

  def authorized?(entity_clazz:, id:)
    return false unless entity_clazz.present? && id.present?

    authorization_by_id(entity_clazz: entity_clazz, id: id)
  end

  private

  def permission_to_entity_name(permission:)
    permission.gsub('_creation', '').gsub('_assertion', '').camelcase
  end

  def permission_authorized?(entity_clazz:)
    # Determine if the requested entity is authorized for the app
    rules.keys.select do |k|
      clazz_name = permission_to_entity_name(permission: k)
      clazz_name == entity_clazz.name && send("#{k}?")
    end
  end

  def authorization_by_rules(entity_clazz:)
    perms = permission_authorized?(entity_clazz: entity_clazz)
    return [] if perms.empty?

    ActiveRecord::Base.connection.execute(rules[perms.first].to_s).map { |r| r[0] }.uniq
  end

  def authorization_by_id(entity_clazz:, id:)
    perms = permission_authorized?(entity_clazz: entity_clazz)
    return false if perms.empty?

    rule = rules[perms.first].to_s.gsub(/;$/, '')
    has_where = rule.split(' from ').last.downcase.match?(/\s+where\s+/)
    rule += " #{has_where ? 'AND' : 'WHERE' } #{entity_clazz.table_name}.id = %{id};" % { id: id }
    ActiveRecord::Base.connection.execute(rule).map { |r| r[0] }.any?
  end
end
