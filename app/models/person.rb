# frozen_string_literal: true

# A person
class Person < ApplicationRecord
  self.table_name = 'persons'

  include Identifiable

  # Associations
  has_many :person_data_management_plans
  has_many :data_management_plans, through: :person_data_management_plans
  has_many :projects, through: :data_management_plans

  # Validations
  validates :name, presence: true

  def to_json(options = [])
    payload = super((%i[name] + options).uniq)
    payload = payload.merge(to_local_json) unless options.include?(:full_json)
    payload
  end

  private

  def to_local_json
    payload = {}
    payload['data_management_plans'] = person_data_management_plans.map do |pd|
      JSON.parse(pd.data_management_plan.to_hateoas("#{pd.role}_of"))
    end
    payload
  end
end
