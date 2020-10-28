# frozen_string_literal: true

namespace :citations do
  desc 'Searches various APIs for citations for DOIs.'
  task scan: :environment do
    # Enqueue the CitationService job
    p 'Starting FindCitationsJob which will load citations from the Datacite and Crossref APIs.'
    p 'This service will only scan for DOIs that:'
    p '   - have an existing citation that is older than 30 days'
    p '   - have no citation'

    fetch_dois.each do |doi|
      record_result(doi: doi&.value, result: ExternalApis::CitationService.fetch(id: doi))
      # Need to sleep to prevent hitting the rate limits
      sleep 1.5
    rescue StandardError => e
      p "Unable to fetch citation for doi: #{doi&.value} -- #{e.message}"
      next
    end
  end

  private

  def fetch_dois
    cut_off_date = Time.now - 31.days

    dois = Identifier.includes(:citation)
                     .where(identifiable_type: 'DataManagementPlan', category: 'doi')
                     .where.not(descriptor: 'is_identified_by')
    return [] unless dois.any?

    dois.select do |id|
      !id.citation.present? ||
        id.citation.retrieved_on <= cut_off_date ||
        id.citation.citation_text.start_with?('Unable to find a citation')
    end
  end

  def record_result(doi:, result:)
    p "Citation found for doi: #{doi}" if result.is_a?(Citation)
    p "Unable to fetch citation for doi: #{doi} - did not return a Citation" unless result.is_a?(Citation)
  end
end
