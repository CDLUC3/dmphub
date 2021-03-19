# frozen_string_literal: true

namespace :ror do
  desc 'Populate missing Crossref funder IDs'
  task fix_fundref: :environment do
    ror_provenance = Provenance.find_by(name: 'ror')

    Affiliation.includes(:identifiers).each do |affiliation|
      if affiliation.fundrefs.empty?
        term = affiliation.name.gsub(/\(.*\)$/, '').strip
        p "#{term} has no Fundrefs!"

        resp = AffiliationSelection::SearchService.search_externally(search_term: term)
        if resp.any?
          # If the names match exactly use it otherwise report out the names of the ones we found
          if resp.first[:name].gsub(/\(.*\)$/, '').strip.downcase == term.downcase && resp.first[:fundref].present?
            affil = resp.first
            p "    Found: #{affil[:name]} - ror: #{affil[:ror]}, fundref: #{affil[:fundref]}"

            p "    Adding Fundref."
            Identifier.create(identifiable: affiliation, provenance: ror_provenance,
                              value: "https://doi.org/10.13039/#{affil[:fundref]}",
                              category: 'fundref', descriptor: 'is_identified_by')

            if affiliation.rors.empty?
              p "    Adding ROR."
              Identifier.create(identifiable: affiliation, provenance: ror_provenance,
                                value: "https://ror.org/#{affil[:ror]}",
                                category: 'ror', descriptor: 'is_identified_by')
            end
          else
            p "First record was not an exact match. Found the following from ROR API (you may need to add manually):"
            resp.each { |r| p "    '#{r[:name]}', ror: #{r[:ror]}, fundref: #{r[:fundref]}" }
          end
        end
      end
    end
  end
end
