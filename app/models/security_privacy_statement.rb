# frozen_string_literal: true

# A Dataset Security and Privacy Statement
class SecurityPrivacyStatement < ApplicationRecord
  include Authorizable
  
  # Associations
  belongs_to :dataset, optional: true

  # Validations
  validates :title, presence: true

  # Scopes
  class << self
    def from_json!(provenance:, json:, dataset:)
      return nil unless json.present? && provenance.present? && dataset.present?

      json = json.with_indifferent_access
      return nil unless json['title'].present?

      statement = find_or_initialize_by(title: json['title'], dataset: dataset)
      statement.description = json['description'] if json['description'].present?
      statement.save
      statement
    end
  end
end
