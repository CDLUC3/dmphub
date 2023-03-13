# frozen_string_literal: true

require 'uc3-citation'

namespace :citations do
  include Uc3Citation

  desc 'Searches various APIs for citations for DOIs.'
  task scan: :environment do
    # Enqueue the CitationService job
    p 'Starting FindCitationsJob which will load citations from the Datacite and Crossref APIs.'
    p 'This service will only scan for DOIs that:'
    p '   - have no citation'

    fetch_dois.each do |doi|
      doi.send(:load_citation)
    rescue StandardError => e
      p "Unable to fetch citation for doi: #{doi&.value} -- #{e.message}"
      next
    end
  end

  private

  def fetch_dois
    dois = Identifier.includes(:citation)
                     .where(identifiable_type: 'DataManagementPlan', category: 'doi')
                     .where.not(descriptor: 'is_identified_by')
    return [] unless dois.any?

    dois.select do |id|
      !id.citation.present? ||
        id.citation.citation_text&.start_with?('Unable to find a citation')
    end
  end
end
