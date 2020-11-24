# frozen_string_literal: true

# Presenter logic for the DMP landing pages
class LandingPresenter
  class << self
    # Fetch the identifier for the DMP's narrative
    def narrative_url(data_management_plan:)
      data_management_plan.identifiers.where(descriptor: 'is_metadata_for').last
    end

    # Detects the primary funder name
    def primary_funder(data_management_plan:)
      return 'DMPHub' unless data_management_plan.present? && data_management_plan.project.present?

      funders = data_management_plan.project.fundings.map(&:affiliation)
      return 'DMPHub' unless funders.any?

      funders.last.name
    end

    # Converts the ContributorDataManagementPlan array into an array of Contributors with Roles
    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def contributors_with_roles(contributors_data_management_plans: [])
      return [] unless contributors_data_management_plans.any?

      contributors = contributors_data_management_plans.map(&:contributor).compact.uniq
      out = contributors.map do |c|
        { contributor: c, roles: contributors_data_management_plans.select { |cdmp| cdmp.role if cdmp.contributor == c }.map(&:role) }
      end
      out.sort { |a, b| a[:contributor]&.name <=> b[:contributor]&.name }
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    def related_datasets(data_management_plan:)
      return [] unless data_management_plan.present? && data_management_plan.identifiers.any?

      # TODO: Implement something that checks/helps us distinguish a dataset from a publication!
      data_management_plan.identifiers.select { |id| id.descriptor = 'is_referenced_by' }
    end

    def related_publications(data_management_plan:)
      return [] unless data_management_plan.present? && data_management_plan.urls.any?

      # TODO: Implement something that checks/helps us distinguish a dataset from a publication!
      data_management_plan.identifiers.reject { |id| id.category == 'ark' }
    end
  end
end
