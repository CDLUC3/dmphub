# frozen_string_literal: true

# A Person to Organization Relationship
class PersonOrganization < ApplicationRecord
  self.table_name = 'persons_organizations'

  # Associations
  belongs_to :organization
  belongs_to :person
end
