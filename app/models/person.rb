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

  # Validations
  validates :name, presence: true

  # Callbacks
  #before_create :creatable?

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? && json['name'].present?

      json = json.with_indifferent_access
      person = new(name: json['name'], email: json['mbox'])
      json.fetch('user_ids', json.fetch('contact_ids', [])).each do |identifier|
        next unless identifier['value'].present?

        ident = {
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value']
        }
        person.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      end
      person
    end

  end

  # Instance Methods

  private

  # Will cancel a create if the record already exists
  def creatable?
    #return false if Person.where(email: email).any?
    #identifiers.each { |identifier| return false if identifier.exists? }
    #true
  end
end
