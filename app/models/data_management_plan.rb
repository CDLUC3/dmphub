# frozen_string_literal: true

# A data management plan
# rubocop:disable Metrics/ClassLength
class DataManagementPlan < ApplicationRecord
  include Authorizable
  include Identifiable

  # Associations
  belongs_to :oauth_authorization, foreign_key: 'id', optional: true, dependent: :destroy
  belongs_to :project, optional: true

  has_many :person_data_management_plans, dependent: :destroy
  has_many :persons, through: :person_data_management_plans
  has_many :costs, dependent: :destroy
  has_many :datasets, dependent: :destroy
  has_many :history, class_name: 'ApiClientHistories', dependent: :destroy

  accepts_nested_attributes_for :costs, :datasets,
                                :person_data_management_plans

  # Validations
  validates :title, presence: true

  # Callbacks
  before_validation :ensure_dataset

  # Scopes
  scope :by_client, lambda { |client_id:|
    where(id: OauthAuthorization.where(oauth_application_id: client_id).pluck(:data_management_plan_id))
  }

  # Class Methods
  class << self
    # Common Standard JSON to an instance of this object
    def from_json!(provenance:, json:, project: nil)
      return nil unless json.present? && provenance.present?

      json = json.with_indifferent_access

      dmp = find_by_identifiers(
        provenance: provenance,
        json_array: json['dmpIds']
      )

      dmp = DataManagementPlan.find_or_initialize_by(project: project, title: json['title']) unless dmp.present?

      DataManagementPlan.transaction do

        dmp.description = json['description'] if json['description'].present?
        dmp.language = json.fetch('language', 'en')
        dmp.ethical_issues = ConversionService.yes_no_unknown_to_boolean(json['ethicalIssuesExist'])
        dmp.ethical_issues_description = json['ethicalIssuesDescription'] if json['ethicalIssuesDescription'].present?
        dmp.ethical_issues_report = json['ethicalIssuesReport'] if json['ethicalIssuesReport'].present?

        dmp.project = project if project.present?
        dmp.project = Project.from_json!(provenance: provenance, json: json['project'], data_management_plan: dmp) unless project.present?

        # Handle the primary contact for the DMP
        if json['contact'].present?
          contact = Person.from_json!(json: json['contact'], provenance: provenance)
          pdmp = PersonDataManagementPlan.new(
            role: 'primary_contact', person: contact
          )
          dmp.person_data_management_plans << pdmp unless dmp.person_exists?(person_data_management_plan: pdmp)
        end

        # Handle other persons related to the DMP
        json.fetch('dmStaff', []).each do |staff|
          person = Person.from_json!(json: staff, provenance: provenance)
          pdmp = PersonDataManagementPlan.new(
            role: staff.fetch('contributorType', 'author'), person: person
          )
          dmp.person_data_management_plans << pdmp unless dmp.person_exists?(person_data_management_plan: pdmp)
        end

        json.fetch('datasets', []).each do |dataset|
          dataset = Dataset.from_json!(json: dataset, provenance: provenance, data_management_plan: dmp)
          dmp.datasets << dataset unless dmp.datasets.include?(dataset)
        end

        json.fetch('costs', []).each do |cost|
          cost = Cost.from_json!(json: cost, provenance: provenance, data_management_plan: dmp)
          dmp.costs << cost unless dmp.costs.include?(cost)
        end

        json.fetch('dmpIds', []).each do |id|
          identifier = Identifier.from_json(provenance: provenance, json: id)
          dmp.identifiers << identifier unless dmp.identifiers.include?(identifier)
        end

        dmp.save
        dmp
      end

    end

    def find_by_organization(organization_id:)
      return all unless organization_id.present?

      joins(:identifiers, person_data_management_plans: { person: :person_organizations} )
        .joins('INNER JOIN organizations p_org ON `persons_organizations`.`organization_id` = p_org.id')
        .includes(:identifiers, person_data_management_plans: { person: :person_organizations} )
        .where('p_org.id = ?', organization_id)
    end

    def find_by_funder(organization_id:)
      return all unless organization_id.present?

      joins(:identifiers, project: :awards)
        .joins('INNER JOIN organizations a_org ON `awards`.`organization_id` = a_org.id')
        .includes(:identifiers, project: :awards)
        .where('a_org.id = ?', organization_id)
    end
  end

  # Instance Methods

  def primary_contact
    PersonDataManagementPlan.where(data_management_plan_id: id, role: 'primary_contact').first
  end

  def persons
    PersonDataManagementPlan.where(data_management_plan_id: id).where.not(role: 'primary_contact')
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

  def errors
    identifiers.each { |identifier| super.copy!(identifier.errors) }
    datasets.each { |dataset| super.copy!(dataset.errors) }
    costs.each { |cost| super.copy!(cost.errors) }
    person_data_management_plans.each { |pdmp| super.copy!(pdmp.errors) }
    super
  end

  # Determine if the person is already associated with the DMP in a specific role
  # This method is necessary because the dmp has not been saved and therefore
  # the normal equality check always passes
  def person_exists?(person_data_management_plan:)
    pdmps = person_data_management_plans.select do |pdmp|
      pdmp.person == person_data_management_plan.person && pdmp.role == person_data_management_plan.role
    end
    pdmps.any?
  end

  private

  # Create a default stub dataset unless one exists
  def ensure_dataset
    return true if datasets.any?

    datasets << Dataset.new(title: title)
  end
end
# rubocop:enable Metrics/ClassLength
