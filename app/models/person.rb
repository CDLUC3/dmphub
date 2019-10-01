# frozen_string_literal: true

# A person
class Person < ApplicationRecord
  self.table_name = 'persons'

  include Identifiable

  # Associations
  has_many :person_data_management_plans
  has_many :data_management_plans, through: :person_data_management_plans
  has_many :projects, through: :data_management_plans
  has_many :person_organizations
  has_many :organizations, through: :person_organizations

  accepts_nested_attributes_for :identifiers, :organizations

  # Validations
  validates :name, presence: true

  # Class Methods
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? && json['name'].present?

      json = json.with_indifferent_access

      # Check any identifiers to see if the person already exists
      person = initialize_from_json(provenance: provenance, json: json)

      # Update the values if they were previously empty
      person.name = json['name'] unless person.name.present?
      person.email = json['mbox'] unless person.email.present?

      identifiers_from_json(provenance: provenance, json: json, person: person)
      organizations_from_json(provenance: provenance, json: json, person: person)
      person
    end

    private

    def initialize_from_json(provenance:, json:)
      ids = json.fetch('user_ids', json.fetch('contact_ids', []))
      person = find_by_identifiers(provenance: provenance, json_array: ids) if ids.any?
      person = find_or_initialize_by(email: json['mbox']) if person.nil?
      person
    end

    def identifiers_from_json(provenance:, json:, person:)
      # Attach any identifiers
      json.fetch('user_ids', json.fetch('contact_ids', [])).each do |identifier|
        ident = Identifier.from_json(provenance: provenance, json: {
                                       category: identifier.fetch('category', 'url'),
                                       value: identifier['value'],
                                       descriptor: 'identified_by'
                                     })
        person.identifiers << ident unless person.identifiers.include?(ident) || ident.nil?
      end
    end

    def organizations_from_json(provenance:, json:, person:)
      # Attach any organizations
      json.fetch('organizations', []).each do |org|
        org = Organization.from_json(json: org, provenance: provenance)
        person.organizations << org unless person.organizations.include?(org)
      end
    end
  end

  # Instance Methods
  def orcid
    identifiers.select { |identifier| identifier.category == 'orcid' }.first
  end
end
