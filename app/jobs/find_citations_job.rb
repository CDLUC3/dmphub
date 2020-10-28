# frozen_string_literal: true

# A job used to take a given DOI and locate any related workss from the pidGraph.
# The results are then combined with the known relatedIdentifiers and converted
# into citations before being returned to the client.
class FindCitationsJob < ApplicationJob
  queue_as :default

  # Make sure this job runs everyday at 6pm Pacific
  after_perform { self.class.set(wait: 1.day).perform_later }

  def perform
    cut_off_date = Time.now - 31.days

    dois = Identifier.includes(:citation)
                     .where(identifiable_type: 'DataManagementPlan', category: 'doi')
                     .where.not(descriptor: 'is_identified_by')
    return true unless dois.any?

    dois.select { |id| !id.citation.present? || id.citation.retrieved_on <= cut_off_date }.each do |doi|
      ExternalApis::CitationService.fetch(id: doi)
      # Need to sleep to prevent hitting the rate limits
      sleep 1.5
      Rails.logger.info "Citation found for DMP: #{dmp.id}, doi: #{doi.value}"
    rescue StandardError => e
      Rails.logger.error "Unable to fetch citation for DMP: #{dmp.id}, doi: #{doi&.value} -- #{e.message}"
      next
    end
  end
end
