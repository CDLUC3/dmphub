# frozen_string_literal: true

# == Schema Information
#
# Table name: data_management_plans
#
#  id                         :bigint           not null, primary key
#  title                      :string(255)      not null
#  language                   :string(255)      not null
#  ethical_issues             :boolean
#  description                :text(4294967295)
#  ethical_issues_description :text(4294967295)
#  ethical_issues_report      :text(4294967295)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  project_id                 :bigint
#  provenance_id              :bigint
#  version                    :datetime
#
# A data management plan
# rubocop:disable Metrics/ClassLength
class DataManagementPlan < ApplicationRecord
  include Alterable
  include Authorizable
  include Identifiable

  # Associations
  belongs_to :project, optional: true

  has_many :contributors_data_management_plans, dependent: :destroy
  has_many :contributors, through: :contributors_data_management_plans
  has_many :costs, dependent: :destroy
  has_many :datasets, dependent: :destroy
  has_many :history, class_name: 'ApiClientHistory', dependent: :destroy

  accepts_nested_attributes_for :costs, :datasets, :project,
                                :contributors_data_management_plans

  # Validations
  validates :title, presence: true

  # Callbacks
  before_validation :ensure_dataset

  after_update :check_version, if: :saved_change_to_version?

  after_touch :check_version

  # Scopes
  scope :by_client, lambda { |client_id:|
    where(api_client_id: client_id)
  }

  scope :search, lambda { |term:|
    clause = <<-SQL
      data_management_plans.title LIKE ?
        OR projects.title LIKE ?
        OR data_management_plans.description LIKE ?
        OR identifiers.value = ?
        OR contributors.name LIKE ?
        OR contributors.email = ?
    SQL
    left_outer_joins(:project, :identifiers, contributors_data_management_plans: :contributor)
      .where(clause, "%#{term}%", "%#{term}%", "%#{term}%", term, "%#{term}%", term)
      .distinct
      .order(updated_at: :desc)
  }

  # Class Methods
  class << self
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
    contributors_data_management_plans.select { |cdmp| cdmp.role == 'primary_contact' }
                                      .first&.contributor
  end

  # rubocop:disable Style/GuardClause
  def primary_contact=(contributor)
    if contributor.is_a?(Contributor)
      # See if there is already a Primary Contact defined.
      prim = primary_contact
      current = contributors_data_management_plans.select { |cdmp| cdmp.role == 'primary_contact' } if prim.present?

      # Remove the old contact
      contributors_data_management_plans.delete(current) if current.present? && prim != contributor

      # Add the new contact
      if prim != contributor
        contributors_data_management_plans << ContributorsDataManagementPlan.new(
          contributor: contributor, role: 'primary_contact', provenance: contributor.provenance
        )
      end
    end
  end
  # rubocop:enable Style/GuardClause

  def doi
    identifiers.select { |d| d.descriptor == 'is_identified_by' && %w[ark doi].include?(d.category) }
               .compact.first
  end

  def doi_without_prefix
    value = doi&.value
    return nil unless value.present?

    ark_prefix = Rails.configuration.x.ezid[:ark_prefix]
    doi_prefix = Rails.configuration.x.ezid[:doi_prefix]

    value = value.gsub(doi_prefix, 'doi:') if doi_prefix.present?
    ark_prefix.present? ? value.gsub(ark_prefix, 'ark:') : value
  end

  def mint_doi(provenance:)
    # When running in Dev mode just generate a random DOI value
    ids = if Rails.env.development?
            [
              Identifier.new(
                value: mock_doi,
                descriptor: 'is_identified_by',
                category: 'doi',
                provenance: provenance
              )
            ]
          else
            # retrieve the Datacite Provenance or initialize it
            ExternalApis::EzidService.mint_doi(
              data_management_plan: self,
              provenance: provenance
            )
          end
    identifiers << ids.flatten.compact
    doi.present? || arks.any?
  end

  private

  # Create a default stub dataset unless one exists
  def ensure_dataset
    datasets << Dataset.new(title: title, provenance: provenance) unless datasets.any?
  end

  # If the version of the DMP has changed and we have a DOI then we need to send an update to EZID
  def check_version
    return true unless doi.present? && !Rails.env.development?

    ExternalApis::EzidService.update_doi(data_management_plan: self)
  end

  # Generate a mock/fake DOI
  def mock_doi
    mocked = 'https://doi.org/'
    mocked += "#{Faker::Number.number(digits: 2)}.#{Faker::Number.number(digits: 4)}"
    "#{mocked}/#{Faker::Alphanumeric.alphanumeric(number: 6)}"
  end
end
# rubocop:enable Metrics/ClassLength
