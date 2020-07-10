# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert RDA Common Standard into a Contributor
      class Contributor
        class << self
          # Convert the incoming JSON into a Contributor
          #   {
          #     "roles": [
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
          def deserialize(provenance:, json: {}, is_contact: false)
            return nil unless valid?(is_contact: is_contact, json: json)

            contributor = marshal_contributor(provenance: provenance,
                                              is_contact: is_contact, json: json)
            return nil unless contributor.valid?

            attach_identifier(provenance: provenance, contributor: contributor, json: json)
          end

          private

          # The JSON is valid if the Contributor has a name or email
          # and roles (if this is not the Contact)
          def valid?(is_contact:, json: {})
            return false unless json.present?

            return false unless json[:name].present? || json[:mbox].present?

            is_contact ? true : json[:roles].present?
          end

          # Find or initialize the Contributor
          def marshal_contributor(provenance:, is_contact:, json: {})
            return nil unless json.present?

            # Try to find the Org by the identifier
            contributor = find_by_identifier(provenance: provenance, json: json)

            # Search by email if available and not found above
            contributor = find_by_email_or_name(provenance: provenance, is_contact: is_contact, json: json) unless contributor.present?

            # Attach the Affiliation unless its already defined
            contributor.affiliation = deserialize_affiliation(provenance: provenance, json: json)

            # Assign the roles
            contributor = assign_contact_roles(contributor: contributor) if is_contact
            assign_roles(contributor: contributor, json: json) unless is_contact

            contributor
          end

          # Locate the Contributor by its identifier
          def find_by_identifier(provenance:, json: {})
            id = json.fetch(:contributor_id, json.fetch(:contact_id, {}))
            return nil unless id[:identifier].present?

            id = Api::V0::Deserialization::Identifier.deserialize(provenance: provenance,
                                                                  identifiable: nil,
                                                                  json: json)
            id.present? ? id.identifiable : nil
          end

          # Find the Contributor by its name or email or initialize one
          def find_by_email_or_name(provenance:, is_contact:, json: {})
            return nil unless valid?(is_contact: is_contact, json: json)

            # Search the DB for the email
            contributor = find_by_email(json: json) if json[:mbox].present?
            return contributor if contributor.present?

            # Search the DB for the name
            find_by_name(provenance: provenance, json: json)
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

          # Assign the default Contact roles
          def assign_contact_roles(contributor:)
            return nil unless contributor.present?

            role = Api::V0::ConversionService.to_credit_taxonomy(role: 'data_curation')
            contributor.roles = [] unless contributor.roles.present?
            contributor.roles << role unless contributor.roles.include?(role)
            contributor
          end

          # Assign the specified roles
          def assign_roles(contributor:, json: {})
            return nil unless contributor.present?
            return contributor unless json.present? && json[:roles].present?

            json.fetch(:roles, []).each do |role|
              url = role.starts_with?('http') ? role : Api::V0::ConversionService.to_credit_taxonomy(role: role)
              next if contributor.roles.include?(url)

              contributor.roles << url
            end
            contributor
          end

          # Marshal the Identifier and attach it
          def attach_identifier(provenance:, contributor:, json: {})
            id = json.fetch(:contributor_id, json.fetch(:contact_id, {}))
            return contributor unless id[:identifier].present?

            identifier = Api::V0::Deserialization::Identifier.deserialize(
              provenance: provenance, identifiable: contributor, json: id
            )
            contributor.identifiers << identifier if identifier.present? && identifier.new_record?
            contributor
          end
        end
      end
    end
  end
end
