# frozen_string_literal: true

module Api
  module V0
    # Presenter for COntributor info
    class ContributorPresenter
      attr_accessor :contributors, :contributor_roles

      def initialize(cdmps:)
        @contributors = cdmps.map(&:contributor).uniq
        @contributor_roles = {}
        cdmps.each do |cdmp|
          id = cdmp.contributor.id
          @contributor_roles[:"#{id}"] = [] unless @contributor_roles[:"#{id}"].present?
          @contributor_roles[:"#{id}"] << cdmp.role unless cdmp.role == 'primary_contact'
        end
      end

      # Convert the specified role into a CRediT Taxonomy URL
      def role_as_uri(role:)
        return nil unless role.present?

        "#{Contributor::ONTOLOGY_BASE_URL}/#{role.to_s.capitalize}"
      end

      def contributor_id(identifiers:)
        identifiers.select { |id| id.identifier_scheme.name == 'orcid' }.first
      end
    end
  end
end
