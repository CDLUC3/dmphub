# frozen_string_literal: true

# Presenter logic for the DMP landing pages
class LandingPresenter
  class << self
    # Converts the ContributorDataManagementPlan array into an array of Contributors with Roles
    def contributors_with_roles(contributors_data_management_plans: [])
      return [] unless contributors_data_management_plans.any?

      contributors = contributors_data_management_plans.map(&:contributor).compact.uniq
      out = contributors.map do |c|
        { contributor: c, roles: contributors_data_management_plans.select { |cdmp| cdmp.role if cdmp.contributor == c }.map(&:role) }
      end
      out.sort { |a, b| a[:contributor]&.name <=> b[:contributor]&.name }
    end

    def related_datasets(data_management_plan:)
      return [] unless data_management_plan.present? && data_management_plan.identifiers.any?

      # TODO: Implement something that checks/helps us distinguish a dataset from a publication!
      data_management_plan.identifiers.select { |id| id.descriptor = 'is_referenced_by' }
    end

    def related_publications(data_management_plan:)
      return [] unless data_management_plan.present? && data_management_plan.urls.any?

      # TODO: Implement something that checks/helps us distinguish a dataset from a publication!
      data_management_plan.identifiers.select { |id| id.descriptor = 'is_referenced_by' }
    end
  end
end
