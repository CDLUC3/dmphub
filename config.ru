# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

# Enqueue the CitationService job that runs tomorrow at noon. The job itself
# will re-enqueue itself to run daily from that point forward
FindCitationsJob.set(wait_until: Date.tomorrow.noon).perform_later
