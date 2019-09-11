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

  # Scopes
  scope :from_json, ->(json, provenance) do
    return nil unless json.present?

    json = delete_base_json_elements(json)
    args = json.select do |k, v|
      !%w[person_data_management_plans data_management_plans projects identifiers mbox].include?(k)
    end
    person = new(args)

    provenance = provenance || Rails.application.name.downcase
    person.identifiers << Identifier.new(category: 'email', value: json['mbox'], provenance: provenance)
    person.identifiers << json['identifiers'].map { |i| Identifier.from_json(i) }
    person
  end
end
