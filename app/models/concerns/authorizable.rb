# frozen_string_literal: true

# Hook to add association to ApiClientAuthorization
module Authorizable
  extend ActiveSupport::Concern

  included do
    # has_many :authorizations, as: :authorizable, dependent: :destroy
    has_many :authorizations, as: :authorizable, dependent: :destroy,
                              class_name: 'ApiClientAuthorization'

    # Determine whether the ApiClient has Authorization for the Authorizable
    def authorized?(api_client:)
      return false unless api_client.present? && api_client.is_a?(ApiClient)

      ApiClientAuthorization.where(api_client: api_client, authorizable: self).any?
    end

    # Authorize the Authorizable for the ApiClient
    def authorize!(api_client:)
      return false unless api_client.present? && api_client.is_a?(ApiClient)

      authorizations << ApiClientAuthorization.find_or_initialize_by(api_client: api_client,
                                                                     authorizable: self)
      save!
    end
  end
end
