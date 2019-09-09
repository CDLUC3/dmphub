# frozen_string_literal: true

# A data management plan
class Award < ApplicationRecord
  include Identifiable

  # Associations
  belongs_to :project
  has_many :award_statuses

  # Validations
  validates :funder_uri, presence: true

  # Scopes
  scope :from_json, ->(json) do
    return nil unless json.present?

    award = new(delete_base_json_elements(json))
    award.identifiers << json['identifiers'].map { |i| Identifier.from_json(i) } if json['identifiers']
    award.award_statuses << json['identifiers'].map { |s| AwardStatus.from_json(s) } if json['funding_statuses']
    award.project = Project.from_json(json['project']) if json['project']
  end
end
