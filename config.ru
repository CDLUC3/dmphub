# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

# Enqueue the CitationService job that runs today at noon (UTC). The job itself
# will re-enqueue itself to run daily from that point forward
Rails.logger.info "Scheduling FindCitationsJob to run on #{Date.today.noon}. The job run daily afterward"
FindCitationsJob.set(wait_until: Date.today.noon).perform_later
