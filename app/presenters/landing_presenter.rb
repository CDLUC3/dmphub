# frozen_string_literal: true

# Presenter logic for the DMP landing pages
class LandingPresenter
  class << self
    # Fetch the identifier for the DMP's narrative
    def narrative_url(data_management_plan:)
      data_management_plan.identifiers.where(descriptor: 'is_metadata_for').last
    end

    def primary_institution(data_management_plan:)
      return 'DMPHub' unless data_management_plan.is_a?(DataManagementPlan)

      contact = data_management_plan.primary_contact
      return 'DMPHub' unless contact.is_a?(Contributor) && contact.affiliation.is_a?(Affiliation)

      contact.affiliation.name
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

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def byte_size(size:)
      return 'unspecified' unless size.present? && size.is_a?(Numeric) && size.positive?

      hash = { size: size / 1.petabytes, units: 'PB' } if size >= 1.petabytes
      hash = { size: size / 1.terabytes, units: 'TB' } if size >= 1.terabytes && !hash.present?
      hash = { size: size / 1.gigabytes, units: 'GB' } if size >= 1.gigabytes && !hash.present?
      hash = { size: size / 1.megabytes, units: 'MB' } if size >= 1.megabytes && !hash.present?
      hash = { size: size, units: 'bytes' } unless hash.present?

      "#{hash[:size]&.to_i} #{hash[:units]}"
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
