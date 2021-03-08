# frozen_string_literal: true

# Persistence service for use when saving an entire DMP model (e.g. a DMP with project, datasets, etc.)
# rubocop:disable Metrics/ClassLength
class PersistenceService
  class << self
    def process_full_data_management_plan(client:, dmp:, history_description:, mintable: false)
      raise StandardError, 'process_full_data_management_plan failed - No client and or dmp provided!' unless client.present? && dmp.present?

      provenance = Provenance.where(name: client.name).first
      action = dmp.new_record? ? 'add' : 'edit'
      ActiveRecord::Base.transaction do
        dmp = safe_save(dmp: dmp)
        dmp = dmp.reload

        errs = ContextualErrorService.contextualize_errors(dmp: dmp)
        raise StandardError, errs.join(', ') if errs.any?

        dmp.mint_doi(provenance: provenance) if mintable && !dmp.doi.present?

        ApiClientAuthorization.find_or_create_by(authorizable: dmp, api_client: client)
        ApiClientHistory.create(api_client: client, data_management_plan: dmp,
                                change_type: action, description: history_description)
      end
      dmp.reload
    rescue StandardError => e
      p "PersistenceService.process_full_data_management_plan - #{e.message}"
      raise e
    end

    private

    # prevent scenarios where we have two contributors with the same affiliation
    # from trying to create the record twice
    def safe_save(dmp:)
      dmp.project = safe_save_project(project: dmp.project)
      dmp.contributors_data_management_plans = dmp.contributors_data_management_plans.map do |cdmp|
        safe_save_contributor_data_management_plan(cdmp: cdmp)
      end
      dmp.datasets = safe_save_datasets(datasets: dmp.datasets)
      dmp.save
      dmp.reload
    end

    def safe_save_identifier(identifier:)
      return nil unless identifier.present?

      identifier.transaction do
        return identifier.save if identifier.valid?
      end

      Identifier.where(category: identifier.category, value: identifier.value,
                       identifiable: identifier.identifiable)
    end

    def safe_save_project(project:)
      return nil unless project.present?

      project.identifiers.each do |id|
        safe_save_identifier(identifier: id)
      end

      project.fundings.each do |f|
        f.affiliation = safe_save_affiliation(affiliation: f.affiliation)
        f.funded_affiliations = f.funded_affiliations.map do |affil|
          safe_save_affiliation(affiliation: affil)
        end
      end

      project.transaction do
        project.save
      end

      project.reload
    end

    def safe_save_datasets(datasets:)
      return [] unless datasets.any?

      datasets.map do |dataset|
        dataset.metadata = dataset.metadata.map do |metadatum|
          safe_save_metadatum(metadatum: metadatum)
        end
        dataset.distributions.each do |distribution|
          distribution.host = safe_save_host(host: distribution.host)
        end
        dataset
      end
    end

    def safe_save_host(host:)
      return host unless host.present? && host.urls.any?

      Host.transaction do
        hst = Host.find_or_create_by(title: host.title)

        if hst.new_record?
          hst.update(saveable_attributes(attrs: host.attributes))
          hst = hst.reload
          host.identifiers.each do |id|
            id.identifiable = hst.reload
            safe_save_identifier(identifier: id)
          end
        end
        hst.reload
      end
    end

    def safe_save_metadatum(metadatum:)
      return metadatum unless metadatum.present? && metadatum.urls.any?

      Metadatum.transaction do
        url = metadatum.urls.first
        id = Identifier.find_or_initialize_by(value: url.value, category: url.category,
                                              descriptor: url.descriptor)
        return id.identifiable unless id.new_record?

        datum = Metadatum.find_or_create_by(description: metadatum.description,
                                            language: metadatum.language)
        id.identifiable = datum
        id.save
        datum.reload
      end
    end

    def safe_save_affiliation(affiliation:)
      return nil unless affiliation.present?

      Affiliation.transaction do
        affil = Affiliation.find_or_create_by(name: affiliation.name)
        if affil.new_record?
          affil.update(saveable_attributes(attrs: affiliation.attributes))
          affiliation.identifiers.each do |id|
            id.identifiable = affil.reload
            safe_save_identifier(identifier: id)
          end
        end
        affil
      end
    end

    def safe_save_contributor_data_management_plan(cdmp:)
      return nil unless cdmp.present? && cdmp.contributor.present?

      cdmp.transaction do
        cdmp.contributor = safe_save_contributor(contributor: cdmp.contributor)
      end
      cdmp
    end

    def safe_save_contributor(contributor:)
      return nil unless contributor.present?

      Contributor.transaction do
        contributor.affiliation = safe_save_affiliation(affiliation: contributor.affiliation)

        contrib = Contributor.find_or_create_by(email: contributor.email) if contributor.email.present?
        contrib = Contributor.find_or_create_by(name: contributor.name) unless contributor.email.present?
        contrib.provenance = contributor.provenance

        if contrib.new_record?
          contrib.update(saveable_attributes(attrs: contributor.attributes))
          contributor.identifiers.each do |id|
            id.identifiable = contrib.reload
            safe_save_identifier(identifier: id)
          end
        end
        contrib.reload
      end
    end

    def saveable_attributes(attrs:)
      %w[id created_at updated_at].each { |key| attrs.delete(key) }
      attrs
    end
  end
end
# rubocop:enable Metrics/ClassLength
