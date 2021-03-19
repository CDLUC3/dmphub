# frozen_string_literal: true

namespace :ezid do
  desc 'Syncs all DMP data with EZID'
  task sync: :environment do
    Identifier.where(category: 'doi', identifiable_type: 'DataManagementPlan',
                     descriptor: 'is_identified_by').each do |identifier|
      dmp = identifier.identifiable
      if ExternalApis::EzidService.verify_doi_exists(data_management_plan: dmp)
        p "Updating EZID's copy of #{dmp.doi_without_prefix} - '#{dmp.title}'"
        ExternalApis::EzidService.update_doi(data_management_plan: dmp)
      end
    end
  end
end
