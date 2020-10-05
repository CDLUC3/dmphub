# frozen_string_literal: true

module Api
  module V0
    # Presenter to help with Affiliations
    class IdentifierPresenter
      class << self
        def dmp_id(identifiers:)
          doi = identifiers.where(category: %w[ark doi]).last
          return doi if doi.present?

          identifiers.where(category: %w[url]).last
        end

        # Returns the DOI/ARK without the URL portion
        def doi_without_host(doi:)
          return doi unless doi.present?
          return doi.gsub(%r{http(s)?://ezid.cdlib.org/id/}, '') if doi.include?('ark:')

          out = doi.gsub(%r{htt(p)s?://doi.org/}, '')
          out.start_with?('doi:') ? out : "doi:#{out}"
        end
      end
    end
  end
end
