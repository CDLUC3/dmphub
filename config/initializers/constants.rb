# frozen_string_literal: true

module Dmphub
  # Custom application configuration
  class Application < Rails::Application
    # -------------------- #
    # APPLICATION SETTINGS #
    # -------------------- #
    config.x.application.helpdesk_email = Rails.application.credentials.dmphub[:helpdesk_email]

    # -------------- #
    # CACHE SETTINGS #
    # -------------- #
    config.x.cache.affiliation_selection_expiration = 1.day

    # ------------- #
    # EZID SETTINGS #
    # ------------- #
    config.x.ezid.landing_page_url = 'https://ezid.cdlib.org/id/'
    config.x.ezid.api_base_url = 'https://ezid.cdlib.org/'
    config.x.ezid.mint_path = 'login'
    config.x.ezid.mint_path = 'id'
    config.x.ezid.delete_path = 'dois/'
    config.x.ezid.doi_prefix = 'https://doi.org/'
    config.x.ezid.ark_prefix = 'https://ezid.cdlib.org/id/ark:'
    config.x.ezid.active = true

    # ----------------- #
    # FUNDER AWARD URLS #
    # ----------------- #
    # Format should be `{ '[ROR]': 'URL' }`
    config.x.funders.award_urls = {
      'https://ror.org/021nxhr62': 'https://www.nsf.gov/awardsearch/showAward?AWD_ID='
    }

    # -------------- #
    # ORCID SETTINGS #
    # -------------- #
    config.x.orcid.uri = 'https://sandbox.orcid.org/'
    config.x.orcid.auth_uri = 'https://sandbox.orcid.org/oauth/authorize'
    config.x.orcid.token_uri = 'https://api.sandbox.orcid.org/oauth/token'
    config.x.orcid.api_base_url = 'https://api.sandbox.orcid.org/v2.1'
    config.x.orcid.active = true

    # ----------------------------------------------------- #
    # ROR Service: https://github.com/ror-community/ror-api #
    # ----------------------------------------------------- #
    config.x.ror.landing_page_url = 'https://ror.org/'
    config.x.ror.api_base_url = 'https://api.ror.org/'
    config.x.ror.heartbeat_path = 'heartbeat'
    config.x.ror.search_path = 'organizations'
    config.x.ror.max_pages = 2
    config.x.ror.max_results_per_page = 20
    config.x.ror.max_redirects = 3
    config.x.ror.active = true

    if Rails.env == 'production'
      # Override default test/development constants here

    end
  end
end
