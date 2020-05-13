# frozen_string_literal: true

# An Organization
class Organization < ApplicationRecord
  include Authorizable
  include Identifiable

  # Associations
  has_many :person_organizations
  has_many :persons, through: :person_organizations

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    super
  end

  # Always return the attrs JSON as a has with indifferent access
  def attrs
    super().with_indifferent_access
  end

  # Scopes
  class << self
    def funders
      joins(:identifiers).includes(:identifiers)
        .where(identifiers: { category: 'doi' })
    end

    def from_json!(provenance:, json:)
      return nil unless json.present? && provenance.present?

      json = json.with_indifferent_access
      return nil unless json['name'].present?

      org = find_by_identifiers(
        provenance: provenance,
        json_array: json['identifiers']
      ) if json['identifiers'].present?

      org = Organization.find_or_initialize_by(name: json['name']) unless org.present?

      # Process any other identifiers
      json.fetch('identifiers', []).each do |id|
        identifier = Identifier.from_json(provenance: provenance, json: id)
        org.identifiers << identifier if identifier.new_record?
      end

      org.save
      org
    end
  end
end
