# frozen_string_literal: true

# A person
class Person < ApplicationRecord
  self.table_name = 'persons'

  include Authorizable
  include Identifiable

  # Associations
  has_many :person_data_management_plans, dependent: :destroy
  has_many :data_management_plans, through: :person_data_management_plans
  has_many :projects, through: :data_management_plans
  has_many :person_organizations, dependent: :destroy
  has_many :organizations, through: :person_organizations, autosave: true

  accepts_nested_attributes_for :identifiers, :organizations

  # Validations
  validates :name, presence: true
  validates :email, uniqueness: { case_sensitive: false }

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    organizations.each { |organization| super.copy!(organization.errors) }
    super
  end

  # Class Methods
  class << self

    # Common Standard JSON to an instance of this object
    def from_json!(provenance:, json:)
      return nil unless json.present? && provenance.present?

      json = json.with_indifferent_access
      return nil unless json['name'].present?

      person = find_by_identifiers(
        provenance: provenance,
        json_array: json.fetch('staffIds', json.fetch('contactIds', []))
      )

      person = Person.find_or_initialize_by(email: json['mbox']) unless person.present?

      # TODO: Figure out when we should overwrite names
      person.name = json['name'] unless person.name.present?

      # Process any other identifiers
      json.fetch('staffIds', json.fetch('contactIds', [])).each do |id|
        identifier = Identifier.from_json(provenance: provenance, json: id)
        person.identifiers << identifier unless person.identifiers.include?(identifier)
      end

      # Process any organizations
      json.fetch('organizations', []).each do |org|
        organization = Organization.from_json!(provenance: provenance, json: org)
        person.organizations << organization unless person.organizations.include?(organization)
      end

      person.save
      person
    end
  end
end
