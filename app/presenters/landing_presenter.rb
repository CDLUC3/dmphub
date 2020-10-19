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
  end
end
