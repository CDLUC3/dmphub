# frozen_string_literal: true

# == Schema Information
#
# Table name: citations
#
#  id            :bigint           not null, primary key
#  identifier_id :bigint           not null
#  provenance_id :bigint           not null
#  object_type   :integer          default("dataset"), not null
#  citation_text :text(65535)
#  original_json :json
#  retrieved_on  :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
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
