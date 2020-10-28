# frozen_string_literal: true

# A job used to take a given DOI and locate any related workss from the pidGraph.
# The results are then combined with the known relatedIdentifiers and converted
# into citations before being returned to the client.
class FindCitationsJob < ApplicationJob
  queue_as :default

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def perform
    cut_off_date = Time.now - 31.days

    DataManagementPlan.joins(:identifiers).includes(identifiers: :citation)
                      .all.each do |dmp|
      dois = dmp.dois.select { |id| id.doi? && !id.is_identified_by? }
      next unless dois.any?

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
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
