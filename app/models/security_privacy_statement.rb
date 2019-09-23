# frozen_string_literal: true

# A Dataset Security and Privacy Statement
class SecurityPrivacyStatement < ApplicationRecord

  # Associations
  belongs_to :dataset, optional: true

  # Validations
  validates :title, presence: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, dataset: nil)
      return nil unless json.present? && provenance.present? && json['title'].present?

      json = json.with_indifferent_access
      statement = find_or_initialize_by(title: json['title'], dataset: dataset)
      statement.description = json['description']
      statement
    end

  end
end
