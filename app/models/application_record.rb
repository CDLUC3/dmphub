# frozen_string_literal: true

# Base Model
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    # Helper method to remove fields from JSON that are managed internally by Rails
    def delete_base_json_elements(json)
      return nil unless json.respond_to?(:[])
      json = json.with_indifferent_access
      json.delete('id') if json['id'].present?
      json.delete('created_at') if json['created_at'].present?
      json.delete('updated_at') if json['updated_at'].present?
      json.delete('links') if json['links'].present?
      json
    end
  end

end
