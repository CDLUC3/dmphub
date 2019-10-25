# frozen_string_literal: true

# A data management plan
# rubocop:disable Metrics/ClassLength
class DataManagementPlan < ApplicationRecord
  include Identifiable

  # Associations
  belongs_to :oauth_authorization, foreign_key: 'id', optional: true, dependent: :destroy
  belongs_to :project

  has_many :person_data_management_plans, dependent: :destroy
  has_many :persons, through: :person_data_management_plans
  has_many :costs, dependent: :destroy
  has_many :datasets, dependent: :destroy

  accepts_nested_attributes_for :costs, :datasets,
                                :person_data_management_plans

  # Validations
  validates :title, :language, presence: true

  # Callbacks
  after_create :ensure_dataset!

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
      dmp = find_by_identifiers(provenance: provenance, json_array: json['dmpIds'])
      dmp = find_or_initialize_by(title: json['title']) unless dmp.present?
      dmp.description = json['description']
      dmp.language = json.fetch('language', 'en')
      dmp.ethical_issues = ConversionService.yes_no_unknown_to_boolean(json['ethicalIssuesExist'])
      dmp.ethical_issues_description = json['ethicalIssuesDescription']
      dmp.ethical_issues_report = json['ethicalIssuesReport']

      dmp.project = project_from_json(provenance: provenance, json: json, dmp: dmp)

      persons_from_json(provenance: provenance, json: json, dmp: dmp)
      identifiers_from_json(provenance: provenance, json: json, dmp: dmp)
      datasets_from_json(provenance: provenance, json: json, dmp: dmp)
      costs_from_json(provenance: provenance, json: json, dmp: dmp)
      dmp
    end

    def persons_from_json(provenance:, json:, dmp:)
      # Handle the primary contact for the DMP
      contact = Person.from_json(json: json['contact'], provenance: provenance)
      pdmp = PersonDataManagementPlan.new(
        role: 'primary_contact', person: contact
      )
      dmp.person_data_management_plans << pdmp unless dmp.person_exists?(person_data_management_plan: pdmp)

      # Handle other persons related to the DMP
      json.fetch('dmStaff', []).each do |staff|
        person = Person.from_json(json: staff, provenance: provenance)
        pdmp = PersonDataManagementPlan.new(
          role: staff.fetch('contributorType', 'author'), person: person
        )
        dmp.person_data_management_plans << pdmp unless dmp.person_exists?(person_data_management_plan: pdmp)
      end
    end

    def project_from_json(provenance:, json:, dmp:)
      if json['project'].present?
        project = Project.from_json(json: json['project'], provenance: provenance)
      end
      return project if project.present?

      Project.new(title: dmp.title, start_on: Time.now, end_on: (Time.now + 2.years))
    end

    def identifiers_from_json(provenance:, json:, dmp:)
      # Handle identifiers, costs and datasets
      json.fetch('dmpIds', []).each do |identifier|
        next unless identifier['value'].present?

        ident = {
          'provenance': provenance.to_s,
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value'],
          'descriptor': 'is_metadata_for'
        }
        id = Identifier.from_json(json: ident, provenance: provenance)
        dmp.identifiers << id unless dmp.identifiers.include?(id)
      end
    end

    def datasets_from_json(provenance:, json:, dmp:)
      json.fetch('datasets', []).each do |dataset|
        dataset = Dataset.from_json(json: dataset, provenance: provenance, data_management_plan: dmp)
        dmp.datasets << dataset unless dataset.nil?
      end
    end

    def costs_from_json(provenance:, json:, dmp:)
      json.fetch('costs', []).each do |cost|
        next unless cost['description'].present?
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

  def doi
    Identifier.find_by(category: 'doi', identifiable_type: 'DataManagementPlan', identifiable_id: id)&.value
  end

  def mint_doi(provenance:)
    doi = DataciteService.mint_doi(
      data_management_plan: self,
      provenance: provenance
    )
    identifiers << Identifier.new(
      category: 'doi',
      provenance: 'datacite',
      value: doi,
      descriptor: 'is_metadata_for'
    )
  end

  def person_exists?(person_data_management_plan:)
    pdmps = person_data_management_plans.select do |pdmp|
      pdmp.person == person_data_management_plan.person && pdmp.role == person_data_management_plan.role
    end
    pdmps.any?
  end

  private

  # Create a default stub dataset unless one exists
  def ensure_dataset!
    return true if datasets.any?

    datasets << Dataset.new(title: title)
    save
  end
end
# rubocop:enable Metrics/ClassLength
