# frozen_string_literal: true

# A job used to take a given DOI and locate any related workss from the pidGraph.
# The results are then combined with the known relatedIdentifiers and converted
# into citations before being returned to the client.
class FindRelatedWorksJob < ApplicationJob
  queue_as :default

  # rubocop:disable Metrics/CyclomaticComplexity
  def perform(*args)
    return nil unless args.first.present? && args.first.is_a?(Hash)

    channel = args.first[:channel]
    dmp = args.first[:dmp]
    return nil unless channel.present? && dmp.present? && dmp.is_a?(DataManagementPlan)

    # Give the page a chance to load before starting
    sleep 1.5

    known_works = process_known_works(channel: channel, dmp: dmp)

    # Fetch additional works from the pidGraph skipping any already in related_identifiers
    known_works = query_pid_graph(channel: channel, doi: dmp.dois.last, known_works: known_works)

    # Do something later
    broadcast_success(channel: channel, done: true) if known_works.any?
    broadcast_failure(channel: channel) unless known_works.any?
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  private

  def broadcast_success(channel:, message: '', done: false)
    ActionCable.server.broadcast channel, { message: message, done: done }
  end

  def broadcast_failure(channel:)
    ActionCable.server.broadcast channel, {
      done: true, message: 'Unable to retrieve related work information at this time.'
    }
  end

  def process_known_works(channel:, dmp:)
    return [] unless channel.present? && dmp.present?

    related_identifiers = LandingPresenter.related_publications(data_management_plan: dmp).map(&:value)
    related_identifiers.each do |doi|
      citation = ExternalApis::CitationService.fetch(doi: doi)
      broadcast_success(channel: channel, message: citation) if citation.present?
    rescue StandardError => e
      Rails.logger.error "FindRelatedWorksJob.perform - channel: '#{channel}', dmp_id: '#{dmp.id}', error: #{e.message}"
      next
    end
    related_identifiers
  end

  def query_pid_graph(channel:, doi:, known_works: [])
    return nil unless channel.present? && doi.present?

    p doi
    p known_works.inspect
    known_works
  end
end
