# frozen_string_literal: true

# An Organization
class Organization < ApplicationRecord

  include Identifiable

  # Associations
  has_many :person_organizations
  has_many :persons, through: :person_organizations

  # Validations
  validates :name, presence: true, uniqueness: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? &&
                        json['name'].present? && json['identifiers'].present?

      json = json.with_indifferent_access
      org = new(name: json['name'])
      json['identifiers'].each do |identifier|
        next unless identifier['value'].present?

        ident = {
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value']
        }
        org.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      end
      org
    end

  end

end
