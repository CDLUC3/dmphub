module Describable
  extend ActiveSupport::Concern

  included do
    has_many :descriptions, as: :describable
  end

end