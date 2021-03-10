# frozen_string_literal: true

# Affiliation controller
class AffiliationsController < ApplicationController
  include AffiliationSelectable

  # POST /affiliations  (via AJAX from Affiliation Typeaheads ... see below for specific pages)
  def search
    # If the search term is greater than 2 characters
    if search_params.present? && search_params.fetch(:q, '').length > 2
      type = search_params.fetch(:type, 'local')

      # If we are including external API results
      affiliations = case type
                     when 'combined'
                       # This type will search both ROR and the local DB giving the local
                       # DB results preference. It is triggered from the following pages:
                       #   Create Account
                       #   Edit Profile
                       #   Admin Edit User
                       #   Contributor Edit/New
                       #   Project Details (Funder selection)
                       #
                       # Those pages use the app/views/shared/affiliation_selectors/_combined.html.erb
                       AffiliationSelection::SearchService.search_combined(search_term: search_params[:q])
                     when 'external'
                       # This type will ONLY check ROR for the specified search term. It
                       # is triggered from the following page:
                       #  SuperAdmin - New Affiliation
                       #
                       # That page uses the app/views/shared/affiliation_selectors/_external_only.html.erb
                       AffiliationSelection::SearchService.search_externally(search_term: search_params[:q])
                     else
                       # This default will ONLY check the local DB's affiliations table. It is
                       # currently not triggered by any pages.
                       #
                       # local DB use the app/views/shared/affiliation_selectors/_local_only.html.erb
                       AffiliationSelection::SearchService.search_locally(search_term: search_params[:q])
                     end

      # If we need to restrict the results to funding affiliations then
      # only return the ones with a valid fundref
      if affiliations.present? && search_params.fetch(:funder_only, 'false') == true
        affiliations = affiliations.select do |affiliation|
          affiliation[:fundref].present? && !affiliation[:fundref].blank?
        end
      end

      results = affiliations.map do |item|
        {
          id: "#{Rails.configuration.x.ror.landing_page_url}#{item[:ror]}",
          value: item[:name]
        }
      end
      render json: results

    else
      render json: []
    end
  end

  private

  def search_params
    params.permit(:q, :funder_only, :type)
  end
end
