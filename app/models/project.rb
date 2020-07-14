# frozen_string_literal: true

# A project
class Project < ApplicationRecord
  include Alterable
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

  # ================ #
  # Instance Methods #
  # ================ #

  private

  # Validator for the Start and End Dates
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def start_on_before_end_on
    errors.add :start_on, 'invalid date format' if start_on.present? && !valid_date?(date: start_on)
    errors.add :end_on, 'invalid date format' if end_on.present? && !valid_date?(date: end_on)
    errors.add :start_on, 'invalid date range (Start must come before end)' if start_on.present? && end_on.present? && start_on > end_on
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # Determines if the date is valid (mySQL does not like dates with a year beyond 4 digits)
  def valid_date?(date:)
    date.respond_to?(:year) && date.year.digits.length == 4
  end
end
