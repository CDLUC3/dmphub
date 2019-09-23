# frozen_string_literal: true

# An Organization
class Organization < ApplicationRecord

  include Identifiable

  # Associations
  has_many :person_organizations
  has_many :persons, through: :person_organizations

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? && json['name'].present?

      json = json.with_indifferent_access
      org = find_by_identifiers(
        provenance: provenance,
        json_array: json['identifiers']
      ) if json['identifiers'].present?

      org = find_or_initialize_by(name: json['name']) unless org.present?

      json['identifiers'].each do |identifier|
        ident = {
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value']
        }
        id = Identifier.from_json(json: ident, provenance: provenance)
        org.identifiers << id unless org.identifiers.include?(id)
      end
      org
    end

  end

end
