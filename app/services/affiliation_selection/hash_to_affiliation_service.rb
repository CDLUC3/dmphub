# frozen_string_literal: true

require 'text'

module AffiliationSelection
  # This class provides conversion methods for turning AffilitionSelection::Search
  # results into Affiliations and Identifiers
  # For example:
  # {
  #   id: 'http://ror.org/123',
  #   name: 'Foo (foo.org)'
  # }
  # becomes:
  # An Affiliation with name = 'Foo (foo.org)',
  #                     identifier (ROR) = 'http://example.org/123'
  #
  class HashToAffiliationService
    class << self
      def to_affiliation(hash:, allow_create: true)
        return nil unless hash.present?

        # 1st: Search by the external ROR identifier and then verify a name match
        affiliation = lookup_affiliation_by_ror(hash: hash)
        return affiliation if affiliation.present?

        # 2nd: Search by name and then verify exact_match
        affiliation = lookup_affiliation_by_name(hash: hash)
        return affiliation if affiliation.present?

        # Otherwise: Create an Affiliation if allowed
        allow_create ? initialize_affiliation(hash: hash) : nil
      end

      private

      # Lookup the Affiliation by its :identifiers and return if the name matches the search
      def lookup_affiliation_by_ror(hash:)
        return nil unless hash.present? && hash[:id].present?

        affiliation = Identifier.where(category: 'ror', value: hash[:id]&.to_s)
        exact_match?(rec: affiliation, name2: hash[:name]&.to_s) ? affiliation : nil
      end

      # Lookup the Affiliation by its :name
      def lookup_affiliation_by_name(hash:)
        clean_name = AffiliationSelection::SearchService.name_without_alias(name: hash[:name]&.to_s)
        affiliation = Affiliation.search(term: clean_name).first
        exact_match?(rec: affiliation, name2: hash[:name]&.to_s) ? affiliation : nil
      end

      # Initialize a new Affiliation from the hash
      def initialize_affiliation(hash:)
        return nil unless hash.present? && hash[:name].present?

        # If the ROR id is present then set the provenance to ROR otherwise it was
        # a manual user entry so just use the DMPHub
        provenance = hash[:id].present? ? Provenance.find_by(name: 'ror') : Provenance.find_by(name: 'dmphub')

        affiliation = Affiliation.new(name: hash[:name], provenance: provenance)
        return affiliation unless hash[:id].present?

        affiliation.identifiers << Identifier.new(
          category: 'ror',
          value: hash[:id],
          descriptor: 'identified_by',
          provenance: provenance
        )
        affiliation
      end

      def exact_match?(rec:, name2:)
        return false unless rec.present? && name2.present?

        AffiliationSelection::SearchService.exact_match?(name1: rec.name, name2: name2)
      end
    end
  end
end
