# frozen_string_literal: true

# Permissions for an ApiClient
class ApiClientPermission < ApplicationRecord
  # Associations
  belongs_to :api_client

  enum permission: %i[data_management_plan_creation award_assertion person_assertion]

  # Retrieve all of the ids of the entities the App has access to using the SQL
  # rule stored in the DB
  def authorized_entities
    return [] unless rule.present?

    ActiveRecord::Base.connection.execute(rule).map { |r| r[0] }.uniq
  end

  # Determine whether the permission grants access to the id
  def authorized?(object:)
    return false unless object.present? && rule.present?
    # return false if we aren't looking for the right model
    return false unless permission.start_with?(object.class.name.underscore)

    # Run the SQL query stored in :rule and splice the id into the query
    sql = rule.gsub(/;$/, '')
    has_where = sql.split(' from ').last.downcase.match?(/\s+where\s+/)
    sql += has_where ? ' AND ' : ' WHERE '
    sql += format("#{object.class.name.pluralize.downcase}.id = %<id>s;", id: object.id)
    ActiveRecord::Base.connection.execute(sql).map { |r| r[0] }.any?
  end
end
