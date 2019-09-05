# frozen_string_literal: true

# A dataset
class Dataset < ApplicationRecord
  include Describable
  include Identifiable

  enum dataset_type: %i[dataset software]

  # Associations
  belongs_to :data_management_plan

  # Validations
  validates :title, :dataset_type, presence: true

  def to_json(options = [])
    payload = super((%i[title dataset_type] + options).uniq)
    payload['personal_data'] = personal_data?
    payload['sensitive_data'] = sensitive_data?
    payload['identifiers'] = identifiers.map { |i| i.to_json }
    payload['descriptions'] = descriptions.map { |d| d.to_json }
    payload = payload.merge(to_local_json) unless options.include?(:full_json)
    payload
  end

  private

  def to_local_json
    payload = {}
    payload['data_management_plan'] = JSON.parse(data_management_plan.to_hateoas('part_of'))
    payload
  end
end
