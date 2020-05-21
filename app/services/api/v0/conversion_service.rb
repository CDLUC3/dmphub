# frozen_string_literal: true

module Api
  module V0
    # Helper to convert common JSON elements
    class ConversionService
      class << self
        # Converts a boolean field to [yes, no, unknown]
        def boolean_to_yes_no_unknown(value)
          return 'yes' if [true, 1].include?(value)

          return 'no' if [false, 0].include?(value)

          'unknown'
        end

        # Converts a [yes, no, unknown] field to boolean (or nil)
        def yes_no_unknown_to_boolean(value)
          return true if value&.downcase == 'yes'

          return nil if value.blank? || value&.downcase == 'unknown'

          false
        end

        # Returns the name of this application
        def local_provenance
          ApplicationService.application_name
        end

        # Translates RDA Common Standard identifier categories
        def to_rda_identifier_category(category:)
          case category
          when 'credit'
            'CRediT'
          else
            category.upcase
          end
        end

        # Translates identifier categories to RDA Common Standard
        def to_identifier_category(rda_category:)
          case rda_category
          when 'CRediT'
            'credit'
          else
            rda_category.downcase
          end
        end

        # Convert from a role to the CRediT URL
        def to_credit_taxonomy(role:)
          "https://dictionary.casrai.org/Contributor_Roles/#{role.capitalize}"
        end

        # Convert from a CRediT URL to a role
        def from_credit_taxonomy(role:)
          role.split('/').last.downcase
        end

        # Converts a User to a Person
        def user_to_person(user:, role:)
          return {} unless user.present? && user.is_a?(User)

          person = Person.find_by_orcid(user.orcid)
          return PersonDataManagementPlan.new(person: person, role: role) if person.present?

          person = Person.find_or_initialize_by(name: user.name, email: user.email)
          person.identifiers << Identifier.find_or_initialize_by(
            provenance: local_provenance, category: 'orcid', value: user.orcid,
            identifiable_type: 'Person'
          )
          PersonDataManagementPlan.new(person: person, role: role)
        end
      end
    end
  end
end
