# frozen_string_literal: true

# A project
class Project < ApplicationRecord
  # Associations
  has_many :awards, dependent: :destroy
  has_many :data_management_plans, dependent: :destroy

  accepts_nested_attributes_for :awards, :data_management_plans

  # Validations
  validates :title, :start_on, :end_on, presence: true

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, data_management_plan: nil)
      return nil unless json.present? && provenance.present? && json['title'].present? &&
                        json['startOn'].present? && json['endOn'].present?

      json = json.with_indifferent_access
      project = data_management_plan.project if data_management_plan.present?
      project = find_or_initialize_by(title: json['title']) unless project.present?
      project.description = json['description']
      project.start_on = json['startOn']
      project.end_on = json['endOn']
      awards_from_json(provenance: provenance, json: json, project: project)
      project
    end

    private

    def awards_from_json(provenance:, json:, project:)
      return unless json['funding'].present? && json['funding'].any?

      json['funding'].each do |award|
        award = Award.from_json(json: award, provenance: provenance, project: project)
        project.awards << award if award.present? && !project.awards.include?(award)
      end
    end
  end
end
