# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert RDA Common Standard into a Funding record
      class Funding
        class << self
          # Convert the Funding information
          #    {
          #      "name": "Example Funder",
          #      "funder_id": {
          #        "type": "ROR",
          #        "identifier": "https://ror.org/43y4g4"
          #      },
          #      "grant_id": {
          #        "type": "URL",
          #        "identifier": "http://example-funder.org/awards/12345"
          #      },
          #      "funding_status": "granted",
          #      "dmproadmap_funding_opportunity_id": {
          #        "type": "other",
          #        "identifier": "NSF-12345"
          #      },
          #      "dmproadmap_funded_affiliations": [
          #        {
          #          "name": "University of Somewhere",
          #          "affiliation_id": {
          #            "type": "ROR",
          #            "identifier": "https://ror.org/43y4g4"
          #          }
          #        }
          #      ]
          #    }
          def deserialize(provenance:, project:, json: {})
            return nil unless provenance.present? && project.present? && valid?(json: json)

            # Lookup the Funder
            affiliation = Api::V0::Deserialization::Affiliation.deserialize(
              provenance: provenance, json: json
            )
            return nil unless affiliation.present?

            funding = find_funding(provenance: provenance, project: project,
                                   affiliation: affiliation, json: json)

            funding = attach_funding_opportunity_id(provenance: provenance, funding: funding, json: json)

            deserialize_funded_affiliations(provenance: provenance, funding: funding, json: json)
          end

          private

          # The JSON is valid if the Funding has a funder name or funder_id
          # or a grant_id
          def valid?(json: {})
            return false unless json.present?

            json[:name].present? || json.fetch(:funder_id, {})[:identifier].present?
          end

          # Find or initialize the Funding
          def find_funding(provenance:, project:, affiliation:, json: {})
            return nil unless json.present?

            funding = ::Funding.find_or_initialize_by(project: project,
                                                      affiliation: affiliation)
            return nil unless funding.present?

            funding.provenance = provenance unless funding.provenance.present?
            funding.status = json[:funding_status]
            return funding unless json[:grant_id].present?

            # Attach the Grant ID/URL
            deserialize_grant(provenance: provenance, funding: funding, json: json)
          end

          # Convert the JSON grant information into an Identifier
          def deserialize_grant(provenance:, funding:, json: {})
            return funding unless json.present? && json[:grant_id].present?

            grant = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: funding, json: json[:grant_id],
              identifiable_type: 'Funding',
              descriptor: 'is_funded_by'
            )
            return funding unless grant.present?

            funding.identifiers << grant unless funding.identifiers&.include?(grant)
            funding
          end

          # Marshal the Fundidng Opportunity Identifier and attach it
          def attach_funding_opportunity_id(provenance:, funding:, json:)
            return funding unless json.present? && json[:dmproadmap_funding_opportunity_id].present?

            opportunity = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: funding, descriptor: 'is_required_by',
              identifiable_type: 'Funding', json: json[:dmproadmap_funding_opportunity_id],
            )
            return funding unless opportunity.present?

            funding.identifiers << opportunity unless funding.identifiers&.include?(opportunity)
            funding
          end

          # Convert the funded_affiliations
          def deserialize_funded_affiliations(provenance:, funding:, json:)
            return funding unless funding.present? && json.present? &&
                                  json.fetch(:dmproadmap_funded_affiliations, []).any?

            json[:dmproadmap_funded_affiliations].each do |affiliation|
              funded = Api::V0::Deserialization::Affiliation.deserialize(
                provenance: provenance, json: affiliation
              )
              next unless funded.present?

              funding.funded_affiliations << funded unless funding.funded_affiliations.include?(funded)
            end
            funding
          end
        end
      end
    end
  end
end
