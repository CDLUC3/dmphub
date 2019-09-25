# frozen_string_literal: true

# A data management plan
class DataManagementPlan < ApplicationRecord
  include Identifiable

  # Associations
  belongs_to :oauth_authorization, foreign_key: 'id', optional: true
  has_many :projects

  has_many :person_data_management_plans
  has_many :persons, through: :person_data_management_plans
  has_many :costs
  has_many :datasets

  # Validations
  validates :title, :language, presence: true

  # Callbacks
  after_create :ensure_dataset!
  after_create :ensure_project!

  # Scopes
  scope :by_client, lambda { |client_id:|
    where(id: OauthAuthorization.where(oauth_application_id: client_id).pluck(:data_management_plan_id))
  }

  # Class Methods
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present?

      json = json.with_indifferent_access
      dmp = find_by_identifiers(provenance: provenance, json_array: json['dmp_ids'])
      dmp = find_or_initialize_by(title: json['title']) unless dmp.present?
      dmp.description = json['description']
      dmp.language = json.fetch('language', 'en')
      dmp.ethical_issues = ConversionService.yes_no_unknown_to_boolean(json['ethical_issues_exist'])
      dmp.ethical_issues_description = json['ethical_issues_description']
      dmp.ethical_issues_report = json['ethical_issues_report']

      persons_from_json(provenance: provenance, json: json, dmp: dmp)
      projects_from_json(provenance: provenance, json: json, dmp: dmp)
      identifiers_from_json(provenance: provenance, json: json, dmp: dmp)
      datasets_from_json(provenance: provenance, json: json, dmp: dmp)
      costs_from_json(provenance: provenance, json: json, dmp: dmp)
      dmp
    end

    def persons_from_json(provenance:, json:, dmp:)
      # Handle the primary contact for the DMP
      contact = Person.from_json(json: json['contact'], provenance: provenance)
      dmp.person_data_management_plans << PersonDataManagementPlan.new(
        role: 'primary_contact', person: contact
      )
      # Handle other persons related to the DMP
      json.fetch('dm_staff', []).each do |staff|
        person = Person.from_json(json: staff, provenance: provenance)
        dmp.person_data_management_plans << PersonDataManagementPlan.new(
          role: staff.fetch('contributor_type', 'author'), person: person
        )
      end
    end

    def projects_from_json(provenance:, json:, dmp:)
      if json['project'].present?
        project = Project.from_json(json: json['project'], provenance: provenance,
                                    data_management_plan: dmp)
      end
      dmp.projects << project if project.present?
    end

    def identifiers_from_json(provenance:, json:, dmp:)
      # Handle identifiers, costs and datasets
      json.fetch('dmp_ids', []).each do |identifier|
        next unless identifier['value'].present?

        ident = {
          'provenance': provenance.to_s,
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value']
        }
        id = Identifier.from_json(json: ident, provenance: provenance)
        dmp.identifiers << id unless dmp.identifiers.include?(id)
      end
    end

    def datasets_from_json(provenance:, json:, dmp:)
      json.fetch('datasets', []).each do |dataset|
        dmp.datasets << Dataset.from_json(json: dataset, provenance: provenance, data_management_plan: dmp)
      end
    end

    def costs_from_json(provenance:, json:, dmp:)
      json.fetch('costs', []).each do |cost|
        dmp.costs << Cost.from_json(json: cost, provenance: provenance, data_management_plan: dmp)
      end
    end
  end

  # Instance Methods

  def primary_contact
    PersonDataManagementPlan.where(data_management_plan_id: id, role: 'primary_contact').first
  end

  def persons
    PersonDataManagementPlan.where(data_management_plan_id: id).where.not(role: 'primary_contact')
  end

  private

  # Create a default stub dataset unless one exists
  def ensure_dataset!
    return true if datasets.any?

    datasets << Dataset.new(title: title)
    save
  end

  # Create a default stub project unless one exists
  def ensure_project!
    return true if projects.any?

    projects << Project.create(title: title, description: description,
                               start_on: Time.now, end_on: Time.now + 2.years)
    save
  end
end
