# frozen_string_literal: true

# Hook to add association to Description
module Describable
  extend ActiveSupport::Concern

  included do
    has_many :descriptions, as: :describable
  end
end
