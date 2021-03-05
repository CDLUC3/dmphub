# frozen_string_literal: true

namespace :upgrade do
  desc 'Upgrade to v0.3.5'
  task v0_3_5: :environment do
    Rake::Task['upgrade:seed_dmp_versions'].execute
  end

  desc 'Initialize the DMP version timestamps with their updated_at dates'
  task seed_dmp_versions: :environment do
    p 'Setting the version timestamp (to the updated_at) for all DMPs that do not have one.'
    DataManagementPlan.where(version: nil).each { |dmp| dmp.update(version: dmp.updated_at) }
  end
end