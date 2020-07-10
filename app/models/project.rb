# frozen_string_literal: true

# A project
class Project < ApplicationRecord
  include Authorizable

  # ============ #
  # Associations #
  # ============ #

  has_many :fundings, dependent: :destroy
  has_many :data_management_plans, dependent: :destroy

  accepts_nested_attributes_for :fundings, :data_management_plans

  # =========== #
  # Validations #
  # =========== #

  validates :title, :start_on, :end_on, presence: true

  validate :start_on_before_end_on

  # ============= #
  # Class Methods #
  # ============= #

  class << self
    # Common Standard JSON to an instance of this object
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def from_json!(provenance:, json:, data_management_plan: nil)
      return nil unless json.present? && provenance.present?
      return nil unless json['title'].present?

      #Project.transaction do
        # If the DMP was provided use its project
        project = data_management_plan.project if data_management_plan.present?

        # TODO: We need a much more sophisticated way to determine if this is a new
        #       Project, title's can and should not be unique!
        project = find_or_initialize_by(title: json['title']) unless project.present?

        json['funding'].each do |funding|
          # funding = Funding.from_json!(provenance: provenance, project: project, json: funding)
          funding = Api::V0::Deserialization::Funding.deserialize(
            provenance: provenance, project: project, json: funding
          )
          project.fundings << funding if funding.present?
        end

        project.description = json['description'] if json['description'].present?
        project.start_on = json[:start] || Time.now.utc
        project.end_on = json[:end] || Time.now.utc + 2.years
        project.save if project.valid?
        project
      #end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end

  # ================ #
  # Instance Methods #
  # ================ #

  private

  def errors
    fundings.each { |funding| super.copy!(funding.errors) }
    data_management_plans.each { |dmp| super.copy!(dmp.errors) }
    super
  end

  # Validator for the Start and End Dates
  def start_on_before_end_on
    errors.add :start_on, 'invalid date format' if start_on.present? && !valid_date?(date: start_on)
    errors.add :end_on, 'invalid date format' if end_on.present? && !valid_date?(date: end_on)
    errors.add :start_on, 'Start date must come before End date' if start_on.present? && end_on.present? && start_on > end_on
  end

  # Determines if the date is valid (mySQL does not like dates with a year beyond 4 digits)
  def valid_date?(date:)
    date.respond_to?(:year) && date.year.digits.length == 4
  end
end
