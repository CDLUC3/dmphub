# frozen_string_literal: true

# A project
class Project < ApplicationRecord

  # Associations
  belongs_to :data_management_plan, optional: true
  has_many :awards, dependent: :destroy

  # Validations
  validates :title, :start_on, :end_on, presence: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, data_management_plan: nil)
      return nil unless json.present? && provenance.present? && json['title'].present? &&
                        json['start_on'].present? && json['end_on'].present?

      json = json.with_indifferent_access
      project = find_or_initialize_by(
        data_management_plan: data_management_plan,
        title: json['title']
      )
      project.description = json['description']
      project.start_on = json['start_on']
      project.end_on = json['end_on']
      return project unless json['funding'].present? && json['funding'].any?

      json['funding'].each do |award|
        project.awards << Award.from_json(json: award, provenance: provenance, project: project)
      end
      project
    end

  end

end
