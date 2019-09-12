# frozen_string_literal: true

# A project
class Project < ApplicationRecord

  # Associations
  has_many :data_management_plans
  has_many :awards, dependent: :destroy

  # Validations
  validates :title, :start_on, :end_on, presence: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? && json['title'].present? &&
                        json['start_on'].present? && json['end_on'].present?

      json = json.with_indifferent_access
      project = new(
        title: json['title'],
        description: json['description'],
        start_on: json['start_on'],
        end_on: json['end_on']
      )
      return project unless json['funding'].present?

      json['funding'].each do |award|
        project.awards << Award.from_json(json: award, provenance: provenance)
      end
      project
    end

  end

end
