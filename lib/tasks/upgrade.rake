# frozen_string_literal: true

namespace :upgrade do
  desc 'Upgrade to v0.3.5'
  task v0_3_5: :environment do
    Rake::Task['upgrade:seed_dmp_versions'].execute
  end

  desc 'Upgrade to v1.0.13'
  task v1_0_13: :environment do
    Rake::Task['upgrade:add_citation_provenance'].execute
    Rake::Task['upgrade:initialize_work_types'].execute
  end

  desc 'Initialize the DMP version timestamps with their updated_at dates'
  task seed_dmp_versions: :environment do
    p 'Setting the version timestamp (to the updated_at) for all DMPs that do not have one.'
    DataManagementPlan.where(version: nil).each { |dmp| dmp.update(version: dmp.updated_at) }
  end

  desc 'Add CitationService as provenance provider for citations'
  task add_citation_provenance: :environment do
    p 'Adding the CitationService as a provenance'
    Provenance.find_or_create_by(
      name: 'citation_service',
      description: 'UC3 CitationService gem that extracts the citation from the DOI registrar.'
    )
  end

  desc 'Seed Identifier.work_type'
  task initialize_work_types: :environment do
    p 'Setting Identifier.work_types based on value of Citation.object_type'
    Citation.includes(:identifier).all.each do |citation|
      case citation.object_type
      when 'article'
        work_type = 'article'
      when 'book'
        work_type = 'book'
      when 'dataset'
        work_type = 'dataset'
      when 'software'
        work_type = 'software'
      else
        work_type = 'supplemental_information'
      end
      citation.identifier&.update(work_type: work_type)
    end
  end
end
