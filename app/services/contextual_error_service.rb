# frozen_string_literal: true

# Persistence service for use when saving an entire DMP model (e.g. a DMP with project, datasets, etc.)
# rubocop:disable Metrics/ClassLength
class ContextualErrorService
  class << self
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def contextualize_errors(dmp:)
      errs = []
      return errs unless dmp.present?

      dmp.datasets.each do |dataset|
        d_errs = find_dataset_errors(dataset: dataset)
        errs << d_errs if d_errs.present?
      end

      dmp.contributors_data_management_plans.each do |cdmp|
        c_errs = find_contributor_errors(cdmp: cdmp)
        errs << c_errs if c_errs.present?
      end

      p_errs = find_project_errors(project: dmp.project)
      errs << p_errs if p_errs.present?

      dmp.costs.each do |cost|
        errs << "Cost: '#{cost.title}' - #{cost.errors.full_messages}" unless cost.valid?
      end

      dmp.identifiers.each do |id|
        errs << "identifier: '#{id.value}' - #{id.errors.full_messages}" unless id.valid?
      end
      errs << "DMP: #{dmp.errors.full_messages}" unless dmp.valid?
      errs.flatten.uniq
      errs
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    # Contextualize errors with the Project and its children
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def find_project_errors(project:)
      errs = []
      return errs unless project.present? && !project.valid?

      f_errs = project.fundings.map do |funding|
        next if funding.valid? && funding.affiliation&.valid?

        a_errs = find_affiliation_errors(affiliation: funding.affiliation) if funding.affiliation.present?
        errs << a_errs if a_errs.any?

        id_errs = funding.identifiers.map do |id|
          next if id.valid?

          "identifier '#{id.value}' : #{id.errors.full_messages}"
        end
        errs << id_errs if id_errs.any?
      end

      errs << f_errs if f_errs.any?
      errs << project.errors.full_messages
      errs = errs.flatten.uniq
      errs.any? ? "Project : #{errs}" : ''
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # Contextualize errors with the Dataset and its children
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def find_dataset_errors(dataset:)
      errs = []
      return errs unless dataset.present? && !dataset.valid?

      sps_errs = dataset.security_privacy_statements.map do |sps|
        next if sps.valid?

        "security privacy statement : #{sps.errors.full_messages}"
      end
      errs << sps_errs if sps_errs.any?

      m_errs = dataset.metadata.map do |metadatum|
        next if metadatum.valid?

        "metadatum : #{metadatum.errors.full_messages}"
      end
      errs << m_errs if m_errs.any?

      d_errs = dataset.distributions.map do |distro|
        next if distro.valid? && distro.host&.valid?

        h_errs = "host '#{distro.host.title}' : #{distro.host.errors.full_messages}" unless distro.host&.valid?
        ["distribution: #{distro.errors.full_messages}", h_errs].join(', ')
      end
      errs << d_errs if d_errs.any?
      errs << dataset.errors.full_messages
      errs = errs.flatten.uniq
      errs.any? ? "Dataset : #{errs}" : ''
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # Contextualize errors with the Affiliation and its children
    def find_affiliation_errors(affiliation:)
      errs = []
      return errs unless affiliation.present? && !affiliation.valid?

      id_errs = affiliation.identifiers.map do |id|
        next if id.valid?

        "identifier '#{id.value}' : #{id.errors.full_messages}"
      end
      errs << id_errs if id_errs.any?
      errs << affiliation.errors.full_messages
      errs = errs.flatten.uniq
      errs.any? ? "Affiliation: '#{affiliation.name}' : #{errs}" : ''
    end

    # Contextualize errors with the ContributorDataManagementPlan and its children
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def find_contributor_errors(cdmp:)
      errs = []
      return errs unless cdmp.present? && (!cdmp.valid? || !cdmp.contributor.valid?)

      a_err = find_affiliation_errors(affiliation: cdmp.contributor.affiliation)
      errs << a_err if a_err.present?

      id_errs = cdmp.contributor.identifiers.map do |id|
        next if id.valid?

        "identifier '#{id.value}' : #{id.errors.full_messages}"
      end
      errs << id_errs if id_errs.any?
      errs << cdmp.contributor.errors.full_messages
      errs << cdmp.errors.full_messages
      errs = errs.flatten.uniq
      errs.any? ? "Contributor/Contact: '#{cdmp.contributor&.name}' : #{errs}" : ''
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
