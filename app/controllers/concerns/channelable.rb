# frozen_string_literal: true

# Methods to assist with ActionCable Channels
module Channelable
  extend ActiveSupport::Concern

  included do
    protected

    # Finds or creates the selected affiliation and then returns it's id
    def doi_to_channel_name(channel_prefix:, doi:, channel_suffix: '')
      return nil unless channel_prefix.present? && doi.present?

      uri = URI.parse(doi) if doi.start_with?('http')
      safe_doi = uri.present? ? uri.path : doi.gsub('doi:', '')
      safe_doi = safe_doi.gsub('/', '').gsub('.', '_')
      [channel_prefix, safe_doi, channel_suffix].join(':')
    end
  end
end
