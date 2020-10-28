# frozen_string_literal: true

# A person
class Citation < ApplicationRecord
  # Associations
  belongs_to :identifier
  belongs_to :provenance

  # Validations
  validates :object_type, :citation_text, :original_json, :retrieved_on, presence: true

  enum object_type: %i[dataset article_journal]

  def to_s
    citation_text.to_s
  end
end
