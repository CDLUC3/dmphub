# frozen_string_literal: true

# Hook to add association to ApiClientAuthorization
module Authorizable
  extend ActiveSupport::Concern

  included do
    has_many :api_clients, as: :authorizable, dependent: :destroy
  end
end
