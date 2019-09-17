# frozen_string_literal: true

# A data management plan
class DataManagementPlan < ApplicationRecord

  include Identifiable

  # Associations
  belongs_to :oauth_authorization, foreign_key: 'id', optional: true
  belongs_to :project, optional: true

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
  scope :by_client, ->(client_id:) do
    ids = OauthAuthorization.where(oauth_application_id: client_id).pluck(:data_management_plan_id)
    where(id: ids)
  end

  # Class Methods
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? &&
                        json['title'].present? && json['contact'].present?

      json = json.with_indifferent_access
      dmp = new(
        title: json['title'],
        description: json['description'],
        language: json.fetch('language', 'en'),
        ethical_issues: ConversionService.yes_no_unknown_to_boolean(json['ethical_issues_exist']),
        ethical_issues_description: json['ethical_issues_description'],
        ethical_issues_report: json['ethical_issues_report']
      )

      # Handle the primary contact for the DMP
      contact = Person.from_json(json: json['contact'], provenance: provenance)
      dmp.person_data_management_plans << PersonDataManagementPlan.new(
        role: 'primary_contact', person: contact)

      # Handle other persons related to the DMP
      json.fetch('dm_staff', []).each do |staff|
        person = Person.from_json(json: staff, provenance: provenance)
        dmp.person_data_management_plans << PersonDataManagementPlan.new(
          role: staff.fetch('contributor_type', 'author'), person: person)
      end

      # Stub out a default Project if none was provided
      project_json = json.fetch('project', {
        title: json['title'],
        description: json['description'],
        start_on: Time.now.to_s,
        end_on: (Time.now + 1.years).to_s
      })
      dmp.project = Project.from_json(json: project_json, provenance: provenance)

      # Handle identifiers, costs and datasets
      json.fetch('dmp_ids', []).each do |identifier|
        next unless identifier['value'].present?
        ident = {
          'provenance': provenance.to_s,
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value']
        }
        dmp.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      end
      json.fetch('costs', []).each do |cost|
        dmp.costs << Cost.from_json(json: cost, provenance: provenance)
      end
      json.fetch('datasets', []).each do |dataset|
        dmp.datasets << Dataset.from_json(json: dataset, provenance: provenance)
      end
      dmp
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
    return true if project.present?

    project = Project.create(title: title, description: description,
      start_on: Time.now, end_on: Time.now + 2.years)
    update(project: project)
  end
end
