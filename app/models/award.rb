# frozen_string_literal: true

# A data management plan
class Award < ApplicationRecord
  include Identifiable

  enum status: %i[planned applied granted rejected]

  # Associations
  belongs_to :project, optional: true

  accepts_nested_attributes_for :identifiers

  # Validations
  validates :funder_uri, :status, presence: true

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, project: nil)
      return nil unless json.present? && provenance.present? && json['funder_id'].present?

      json = json.with_indifferent_access
      award = find_or_initialize_by(project: project, funder_uri: json['funder_id'])
      # TODO: Don't hard code this, either find it in the DB or call Fundref API
      award.funder_name = 'National Science Foundation (NSF)' if award.funder_uri == 'http://dx.doi.org/10.13039/100000001'
      award.status = json.fetch('funding_status', 'planned')
      return award unless json['grant_id'].present?

      # Convert the grant_id into an identifier record
      ident = {
        'category': 'url',
        'value': json['grant_id'],
        'descriptor': 'funded_by'
      }
      id = Identifier.from_json(json: ident, provenance: provenance)
      award.identifiers << id unless award.identifiers.include?(id)
      add_additional_identifiers(provenance: provenance, json: json, award: award)
      award
    end

    private

    def add_additional_identifiers(provenance:, json:, award:)
      json.fetch('award_ids', []).each do |identifier|
        next unless identifier['value'].present?

        ident = {
          'provenance': provenance.to_s,
          'category': identifier.fetch('category', 'url'),
          'value': identifier['value'],
          'descriptor': 'identified_by'
        }
        id = Identifier.from_json(json: ident, provenance: provenance)
        award.identifiers << id unless award.identifiers.include?(id)
      end
    end
  end
end
