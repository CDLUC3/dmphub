# frozen_string_literal: true

# Hook to add association to Identifier
module Identifiable
  extend ActiveSupport::Concern

  included do
    has_many :identifiers, as: :identifiable
  end
end
