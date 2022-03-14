# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert RDA Common Standard into a Contributor
      class Contributor
        class << self
          # Convert the incoming JSON into a Contributor
          #   {
          #     "role": [
          #       "https://dictionary.casrai.org/Contributor_Roles/Project_administration"
          #     ],
          #     "name": "Jane Doe",
          #     "mbox": "jane.doe@university.edu",
          #     "affiliation": {
          #       "name": "University of Somewhere",
          #       "abbreviation": "UofS",
          #       "affiliation_id": {
          #         "type": "ROR",
          #         "identifier": "https://ror.org/43y4g4"
          #       }
          #     },
          #     "contributor_id": {
          #       "type": "ORCID",
          #       "identifier": "https://orcid.org/0000-0000-0000-0000"
          #     }
          #   }
          #
          # NOTE: `role: []` is processed in the DataManagementPlan deserialization service
          #       but included here as a validation check
          def deserialize(provenance:, json: {}, is_contact: false)
            return nil unless valid?(is_contact: is_contact, json: json)

            contributor = marshal_contributor(provenance: provenance,
                                              is_contact: is_contact, json: json)
            return nil unless contributor.present?

            attach_identifier(provenance: provenance, contributor: contributor, json: json)
          end

          private

          # The JSON is valid if the Contributor has a name or email
          # and roles (if this is not the Contact)
          # rubocop:disable Metrics/CyclomaticComplexity
          def valid?(is_contact:, json: {})
            return false unless json.present?
            return false unless json[:name].present? || json[:mbox].present?

            # Make the role an array in the event that it is a string
            json[:role] = [json[:role]] if json[:role].present? && json[:role].is_a?(String)

            is_contact ? true : json[:role].present? && json[:role].any?
          end
          # rubocop:enable Metrics/CyclomaticComplexity

          # Find or initialize the Contributor
          def marshal_contributor(provenance:, is_contact:, json: {})
            return nil unless json.present?

            # Search by email if available and not found above
            contributor = find_by_email_or_name(provenance: provenance, is_contact: is_contact, json: json)
            contributor = attach_identifier(provenance: provenance, contributor: contributor, json: json) unless contributor.present?

            # Try to find the Org by the identifier
            contributor = find_by_identifier(provenance: provenance, json: json) unless contributor.present?
            # Update the email if we found them by identifier
            contributor.email = json[:mbox] if contributor.present? && json[:mbox].present?

            # Attach the Affiliation unless its already defined
            contributor.name = json[:name] if json[:name].present?

            contributor.affiliation = deserialize_affiliation(provenance: provenance, json: json)
            contributor
          end

          # Locate the Contributor by its identifier
          def find_by_identifier(provenance:, json: {})
            id_json = json.fetch(:contributor_id, json.fetch(:contact_id, {}))
            return nil unless id_json[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: nil, json: id_json, descriptor: 'is_identified_by',
              identifiable_type: 'Contributor'
            )
            id.present? && id.identifiable.is_a?(::Contributor) ? id.identifiable : nil
          end

          # Find the Contributor by its name or email or initialize one
          def find_by_email_or_name(provenance:, is_contact:, json: {})
            return nil unless valid?(is_contact: is_contact, json: json)

            # Search the DB for the email
            contributor = find_by_email(json: json) if json[:mbox].present?
            contributor.name = json[:name] if contributor.present? && json[:name].present?
            return contributor if contributor.present?

            # Search the DB for the name
            contributor = find_by_name(provenance: provenance, json: json)
            return contributor if contributor.present?
          end

          # Find the Contributor by email (for the DMP)
          def find_by_email(json: {})
            return nil unless json[:mbox].present?

            ::Contributor.where('LOWER(email) = ?', json[:mbox].downcase).first
          end

          # Find the Contributor by name or initialize a new one
          def find_by_name(provenance:, json: {})
            return nil unless json[:name].present?

            contributor = ::Contributor.where('LOWER(name) = ?', json[:name].downcase).first
            return contributor if contributor.present?

            # If no good result was found just initialize a new one
            ::Contributor.new(provenance: provenance, name: json[:name], email: json[:mbox])
          end

          # Call the deserializer method for the Org
          def deserialize_affiliation(provenance:, json: {})
            return nil unless json.present? && json[:affiliation].present?

            Api::V0::Deserialization::Affiliation.deserialize(
              provenance: provenance, json: json[:affiliation]
            )
          end

          # Marshal the Identifier and attach it
          def attach_identifier(provenance:, contributor:, json: {})
            id_json = json.fetch(:contributor_id, json.fetch(:contact_id, {}))
            return contributor unless id_json[:identifier].present?

            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: contributor, json: id_json, identifiable_type: 'Contributor'
            )
            return contributor unless identifier.present?

            # If the identifier doesn't match the existing one then get rid of the old one
            contributor.identifiers.destroy_all if contributor.identifiers.last&.value != identifier.value
            contributor.identifiers << identifier
            contributor
          end
        end
      end
    end
  end
end
