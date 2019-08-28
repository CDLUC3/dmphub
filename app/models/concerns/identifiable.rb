module Identifiable
  extend ActiveSupport::Concern

  included do
    has_many :identifiers, as: :identifiable
  end

end