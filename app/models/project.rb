# frozen_string_literal: true

# A project
class Project < ApplicationRecord
  include Authorizable

  # Associations
  has_many :awards, dependent: :destroy
  has_many :data_management_plans, dependent: :destroy

  accepts_nested_attributes_for :awards, :data_management_plans

  # Validations
  validates :title, :start_on, :end_on, presence: true

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def from_json!(provenance:, json:, data_management_plan: nil)
      return nil unless json.present? && provenance.present?
      return nil unless json['title'].present?

      Project.transaction do
        # If the DMP was provided use its project
        project = data_management_plan.project if data_management_plan.present?

        # TODO: We need a much more sophisticated way to determine if this is a new
        #       Project, title's can and should not be unique!
        project = find_or_initialize_by(title: json['title']) unless project.present?

        json.fetch('funding', []).each do |award|
          award = Award.from_json!(provenance: provenance, project: project, json: award)
          project.awards << award if award.present?
        end

        project.description = json['description'] if json['description'].present?
        project.start_on = json.fetch('startOn', Time.now.utc)
        project.end_on = json.fetch('endOn', Time.now.utc + 2.years)
        project.save
        project
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end

  # Instance methods
  def errors
    awards.each { |award| super.copy!(award.errors) }
    data_management_plans.each { |dmp| super.copy!(dmp.errors) }
    super
  end
end
