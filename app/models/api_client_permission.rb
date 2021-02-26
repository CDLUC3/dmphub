# frozen_string_literal: true

# == Schema Information
#
# Table name: api_client_permissions
#
#  id            :bigint           not null, primary key
#  api_client_id :bigint           not null
#  permission    :integer          not null
#  rules         :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Permissions for an ApiClient
class ApiClientPermission < ApplicationRecord
  # Associations
  belongs_to :api_client

  enum permission: %i[data_management_plan_creation funding_assertion contributor_assertion]

  # Retrieve all of the ids of the entities the App has access to using the SQL
  # rules stored in the DB
  def authorized_entities
    return [] unless rules.present?

    ActiveRecord::Base.connection.execute(rules).map { |r| r[0] }.uniq
  end

  # Determine whether the permission grants access to the id
  def authorized?(object:)
    return false unless object.present? && rules.present?
    # return false if we aren't looking for the right model
    return false unless permission.start_with?(object.class.name.underscore)

    # Run the SQL query stored in :rules and splice the id into the query
    sql = rules.gsub(/;$/, '')
    has_where = sql.split(' from ').last.downcase.match?(/\s+where\s+/)
    sql += has_where ? ' AND ' : ' WHERE '
    sql += format("#{object.class.name.pluralize.downcase}.id = %<id>s;", id: object.id)
    ActiveRecord::Base.connection.execute(sql).map { |r| r[0] }.any?
  end
end
