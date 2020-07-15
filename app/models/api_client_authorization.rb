# frozen_string_literal: true

# Represents an identifier (e.g. ORCID, email, DOI, etc.)
class ApiClientAuthorization < ApplicationRecord
  # Associations
  belongs_to :api_client
  belongs_to :authorizable, polymorphic: true

  scope :by_api_client_and_type, lambda { |api_client_id:, authorizable_type:|
    where(api_client_id: api_client_id, authorizable_type: authorizable_type.to_s)
  }
end
