# frozen_string_literal: true

# A data management plan
class DataManagementPlan < ApplicationRecord
  include Describable
  include Identifiable

  # Associations
  belongs_to :oauth_authorization, foreign_key: 'id', optional: true
  belongs_to :project
  has_many :person_data_management_plans
  has_many :persons, through: :person_data_management_plans
  has_many :datasets

  # Validations
  validates :title, :language, presence: true
  validates :ethical_issues, inclusion: 0..2

  # Callbacks
  after_create :ensure_dataset!

  # Scopes
  scope :by_client, ->(client_id:) do
    joins(oauth_authorization: :oauth_application).where('oauth_applications.uid = ?', client_id)
  end

  def has_ethical_issues?
    ethical_issues == 0 ? 'no' : ethical_issues == 1 ? 'yes' : 'unknown'
  end

  # JSON for API
  def to_json(options = [])
    payload = super((%i[title language] + options).uniq)
    payload['ethical_issues'] = has_ethical_issues?
    payload['descriptions'] = descriptions.select{ |d| !d.ethical_issue? }.map { |d| d.to_json }
    payload['ethical_issue_descriptions'] = descriptions.select{ |d| d.ethical_issue? }.map { |d| d.to_json }
    payload['ethical_issue_reports'] = []
    payload['identifiers'] = identifiers.map { |i| i.to_json }
    payload = payload.merge(options.include?(:full_json) ? to_full_json : to_local_json)
    payload
  end

  def primary_contact
    PersonDataManagementPlan.where(data_management_plan_id: id, role: 'primary_contact').first
  end

  def persons
    PersonDataManagementPlan.where(data_management_plan_id: id).where.not(role: 'primary_contact')
  end

  private

  def ensure_dataset!
    datasets << Dataset.new(title: title)
    save!
  end

  def to_local_json
    payload = {}
    payload['project'] = JSON.parse(project.to_hateoas('is_supplement_to')) if project.present?
    payload['contact'] = JSON.parse(primary_contact.person.to_hateoas('has_owner')) if primary_contact.present?
    payload['persons'] = persons.map { |p| JSON.parse(p.person.to_hateoas("has_#{p.role}")) }
    payload['datasets'] = datasets.map { |d| JSON.parse(d.to_hateoas('describes')) }
    payload
  end

  def to_full_json
    payload = {}
    payload['project'] = project.to_json(%i[full_json]) if project.present?
    payload['contact'] = primary_contact.to_json(%i[full_json]) if primary_contact.present?
    payload['persons'] = persons.map { |p| p.to_json(%i[full_json]) }
    payload['datasets'] = datasets.map { |d| d.to_json(%i[full_json]) }
    payload
  end

end
