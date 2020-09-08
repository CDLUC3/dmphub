# frozen_string_literal: true

require 'text'

module AffiliationSelection
  # This class provides a search mechanism for Affiliations that looks at records in the
  # the database along with any available external APIs
  class AffiliationToHashService
    class << self
      # Convert an Identifiable Model over to hash results like:
      # An Affiliation with id = 123, name = 'Foo (foo.org)',
      #                identifier (ROR) = 'http://example.org/123'
      # becomes:
      # {
      #   id: '123',
      #   name: 'Foo (foo.org)',
      #   sort_name: 'Foo',
      #   ror: 'http://ror.org/123',
      #   fundref: 'https://api.crossref.org/funders/100000030'
      # }
      def to_hash(affiliation:)
        return {} unless affiliation.present?

        {
          id: affiliation.id,
          name: affiliation.name,
          sort_name: AffiliationSelection::SearchService.name_without_alias(name: affiliation.name),
          ror: affiliation.rors.last&.value || '',
          fundref: affiliation.fundrefs.last&.value || ''
        }
      end
    end
  end
end
