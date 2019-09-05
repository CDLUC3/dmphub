# frozen_string_literal: true

# A data management plan
class Award < ApplicationRecord
  include Identifiable

  # Associations
  belongs_to :project
  has_many :award_statuses

  # Validations
  validates :funder_uri, presence: true

  def to_json(options = [])
    payload = super((%i[funder_uri] + options).uniq)
    payload['funding_statuses'] = award_statuses.map { |s| s.to_json }
    payload['identifiers'] = identifiers.map { |i| i.to_json }
    payload = payload.merge(to_local_json) unless options.include?(:full_json)
    payload
  end

  private

  def to_local_json
    payload = {}
    payload['project'] = JSON.parse(project.to_hateoas('funded'))
    payload
  end
end
