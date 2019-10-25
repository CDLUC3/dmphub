# frozen_string_literal: true

# A data management plan
class Award < ApplicationRecord
  include Identifiable

  enum status: %i[planned applied granted rejected]

  # Associations
  belongs_to :project, optional: true
  belongs_to :organization

  accepts_nested_attributes_for :identifiers

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, project: nil)
      return nil unless json.present? && provenance.present? && json['funderId'].present?

      json = json.with_indifferent_access
      identifier = find_identifier(provenance: provenance, json: json)
      award = Award.find(id: identifier.identifiable_id) if identifier.present?
      # We found a matching award that has already been funded so no updates needed
      return award if award.present?

      funder = organization_from_json(provenance: provenance, json: json)
      awards = Award.where(project: project, organization: funder)
                    .order(created_at: :desc)
      if awards.any?
        # Look for the most recent award that is not rejected/granted
        awards = awards.select { |a| !%w[rejected granted].include?(a.status) }
        if awards.any?
          # There is an Award that has not been grnated or rejected so update it
          award = awards.first
          award.status = json.fetch('fundingStatus', 'planned')
          award.identifiers << identifier if identifier.present?
          award
        else
          # The only awards we know about are already rejected/granted
          # If the incoming status is not also rejected/granted then
          # consider this a new funding attempt
          if !%w[rejected granted].include?(json['fundingStatus'])
            new_award(provenance: provenance, json: json, project: project,
                  funder: funder, identifier: identifier)
          else
            awards.first
          end
        end
      else
        # New funder, so create the Award
        new_award(provenance: provenance, json: json, project: project,
                  funder: funder, identifier: identifier)
      end
    end

    private

    def find_identifier(provenance:, json:)
      Identifier.where(provenance: provenance, identifiable_type: 'Award',
        category: 'url', value: json['grantId']).first
    end

    def organization_from_json(provenance:, json:)
      # find the funder organization
      hash = {
        'name': json['funderName'],
        'identifiers': [{
          'category': 'doi',
          'value': json['funderId']
        }]
      }
      Organization.from_json(provenance: provenance, json: hash)
    end

    def new_award(provenance:, json:, project:, funder:, identifier:)
      award = Award.new(project: project, organization: funder,
                        status: json.fetch('fundingStatus', 'planned'))
      award.identifiers << identifier if identifier.present?
      award
    end
  end
end
