# frozen_string_literal: true

# A data management plan
class PersonDataManagementPlan < ApplicationRecord
  self.table_name = 'persons_data_management_plans'

  enum role: %i[primary_contact curator author]

  # Associations
  belongs_to :data_management_plan
  belongs_to :person

  # Validations
  validates :role, presence: true

  # Renders the person with their role as JSON
  # This method is meant to be called from the DataManagementPlan ONLY
  def to_json(options = [])
    payload = super((%i[role no_hateoas] + options).uniq)
    payload = payload.merge(person.to_json(%i[full_json]))
    payload
  end
end
