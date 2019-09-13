# frozen_string_literal: true

# A data management plan
class Award < ApplicationRecord

  include Identifiable

  enum status: %i[planned applied granted rejected]

  # Associations
  belongs_to :project, optional: true

  # Validations
  validates :funder_uri, :status, presence: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? && json['funder_id'].present?

      json = json.with_indifferent_access
      award = new(
        funder_uri: json['funder_id'],
        status: json.fetch('funding_status', 'planned')
      )
      return award unless award.valid? && json['grant_id'].present?

      # Convert the grant_id into an identifier record
      ident = {
        'provenance': provenance.to_s,
        'category': 'url',
        'value': json.fetch('grant_id', '')
      }
      award.identifiers << Identifier.from_json(json: ident, provenance: provenance)
      award
    end

  end

end
