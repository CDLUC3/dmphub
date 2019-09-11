# frozen_string_literal: true

# A Dataset Technical Resource
class TechnicalResource < ApplicationRecord

  include Identifiable

  # Associations
  belongs_to :dataset

end
