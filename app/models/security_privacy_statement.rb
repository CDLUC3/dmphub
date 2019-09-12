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
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? && json['title'].present?

      json = json.with_indifferent_access
      new(title: json['title'], description: json['description'])
    end

  end
end
