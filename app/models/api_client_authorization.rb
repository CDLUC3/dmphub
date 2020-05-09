# frozen_string_literal: true

# Represents an identifier (e.g. ORCID, email, DOI, etc.)
class ApiClientAuthorization < ApplicationRecord
  # Associations
  belongs_to :api_client
  belongs_to :authorizable, polymorphic: true
end
