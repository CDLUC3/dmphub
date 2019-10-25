# frozen_string_literal: true

# Provides conversion methods for JSON <--> Model
class ConversionService
  class << self
    # Converts a boolean field to [yes, no, unknown]
    def boolean_to_yes_no_unknown(value)
      return 'yes' if value == true

      return 'no' if value == false

      'unknown'
    end

    # Converts a [yes, no, unknown] field to boolean (or nil)
    def yes_no_unknown_to_boolean(value)
      return true if value == 'yes'

      return nil if value.blank? || value == 'unknown'

      false
    end

    # Returns the name of this application
    def local_provenance
      Rails.application.class.name.split('::').first.downcase
    end

    # Translates RDA Common Standard identifier categories
    def to_rda_identifier_category(category:)
      case category
      when 'orcid'
        'HTTP-ORCID'
      when 'ror'
        'HTTP-ROR'
      else
        category.upcase
      end
    end
    def to_identifier_category(rda_category:)
      case rda_category
      when 'HTTP-ORCID'
        'orcid'
      when 'HTTP-ROR'
        'ror'
      else
        rda_category.downcase
      end
    end

    # Converts a User to a Person
    def user_to_person(user:, role:)
      return {} unless user.present? && user.is_a?(User)

      ident = Identifier.find_by(value: user.orcid, category: 'orcid',
                                 provenance: local_provenance, identifiable_type: 'Person')
      person = Person.find(ident.identifiable_id) if ident.present?
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
