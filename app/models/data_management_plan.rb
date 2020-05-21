# frozen_string_literal: true

# A data management plan
# rubocop:disable Metrics/ClassLength
class DataManagementPlan < ApplicationRecord
  include Authorizable
  include Identifiable

  # Associations
  belongs_to :project, optional: true

  has_many :contributors_data_management_plans, dependent: :destroy
  has_many :contributors, through: :contributors_data_management_plans
  has_many :costs, dependent: :destroy
  has_many :datasets, dependent: :destroy
  has_many :history, class_name: 'ApiClientHistory', dependent: :destroy

  accepts_nested_attributes_for :costs, :datasets,
                                :contributors_data_management_plans

  # Validations
  validates :title, presence: true

  # Callbacks
  before_validation :ensure_dataset

  # Scopes
  scope :by_client, lambda { |client_id:|
    where(api_client_id: client_id)
  }

  # Class Methods
  class << self
    # Common Standard JSON to an instance of this object
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def from_json!(provenance:, json:, project: nil)
      return nil unless json.present? && provenance.present?

      json = json.with_indifferent_access

      dmp = find_by_identifiers(
        provenance: provenance,
        json_array: json['dmpIds']
      )

      dmp = DataManagementPlan.find_or_initialize_by(project: project, title: json['title']) unless dmp.present?

      # rubocop:disable Metrics/BlockLength
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
          contact = Contributor.from_json!(json: json['contact'], provenance: provenance)
          pdmp = ContributorsDataManagementPlan.new(
            role: 'primary_contact', person: contact
          )
          dmp.contributors_data_management_plans << pdmp unless dmp.contributor_exists?(contributor_data_management_plan: pdmp)
        end

        # Handle other contributors related to the DMP
        json.fetch('dmStaff', []).each do |staff|
          person = Contributor.from_json!(json: staff, provenance: provenance)
          pdmp = ContributorsDataManagementPlan.new(
            role: staff.fetch('contributorType', 'author'), person: person
          )
          dmp.contributors_data_management_plans << pdmp unless dmp.contributor_exists?(contributor_data_management_plan: pdmp)
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
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def find_by_organization(affiliation_id:)
      return all unless affiliation_id.present?

      joins(:identifiers, contributors_data_management_plans: { contributor: :contributors_affiliations })
        .joins('INNER JOIN affiliations p_org ON `contributors_affiliations`.`affiliation_id` = p_org.id')
        .includes(:identifiers, contributors_data_management_plans: { contributor: :contributors_affiliations })
        .where('p_org.id = ?', affiliation_id)
    end

    def find_by_funder(affiliation_id:)
      return all unless affiliation_id.present?

      joins(:identifiers, project: :awards)
        .joins('INNER JOIN affiliations a_org ON `fundings`.`affiliation_id` = a_org.id')
        .includes(:identifiers, project: :fundings)
        .where('a_org.id = ?', affiliation_id)
    end
  end

  # Instance Methods

  def primary_contact
    ContributorsDataManagementPlan.where(data_management_plan_id: id, role: 'primary_contact').first
  end

  def contributors
    ContributorsDataManagementPlan.where(data_management_plan_id: id).where.not(role: 'primary_contact')
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
    contributors_data_management_plans.each { |pdmp| super.copy!(pdmp.errors) }
    super
  end

  # Determine if the person is already associated with the DMP in a specific role
  # This method is necessary because the dmp has not been saved and therefore
  # the normal equality check always passes
  def contributor_exists?(contributor_data_management_plan:)
    pdmps = contributors_data_management_plans.select do |pdmp|
      pdmp.person == contributors_data_management_plans.contributor && pdmp.role == contributor_data_management_plan.role
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
