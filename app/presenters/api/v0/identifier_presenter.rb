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
      end
    end
  end
end
