# frozen_string_literal: true

# A project
class Project < ApplicationRecord
  include Describable

  # Associations
  has_many :data_management_plans
  has_many :awards

  # Validations
  validates :title, presence: true

  def to_json(options = [])
    payload = super((%i[title] + options).uniq)
    payload['descriptions'] = descriptions.map { |i| i.to_json }
    payload = payload.merge(options.include?(:full_json) ? to_full_json : to_local_json)
    payload
  end

  private

  def to_local_json
    payload = {}
    payload['data_management_plans'] = data_management_plans.map { |dmp| JSON.parse(dmp.to_hateoas('described_by')) }
    payload['awards'] = awards.map { |a| JSON.parse(a.to_hateoas('funded_by')) }
    payload
  end

  def to_full_json
    payload = {}
    payload['awards'] = awards.map { |a| a.to_json(%i[full_json]) }
    payload
  end
end
