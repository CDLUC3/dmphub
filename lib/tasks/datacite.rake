# frozen_string_literal: true

namespace :datacite do
  desc 'Removes all of the `draft` DMPs from Datacite and then deletes them from the Hub'
  task clear_drafts: :environment do
    Identifier.where(category: 'doi', identifiable_type: 'DataManagementPlan').each do |identifier|
      DataManagementPlan.find(identifier.identifiable_id)

      if DataciteService.delete_doi(doi: identifier.value)
        OauthAuthorization.where(data_management_plan_id: identifier.identifiable_id).destroy_all

        p "Unable to delete DMP for: #{identifier.inspect}" unless DataManagementPlan.where(id: identifier.identifiable_id).destroy_all
      else
        p "Unable to delete the DOI for: #{identifier.inspect}"
      end
    end
  end

  desc 'Removes all of the `orphaned` DOIs'
  task clear_orphans: :environment do
    done = false
    until done
      dois = DataciteService.fetch_dois
      done = true if dois.empty?

      dois.each { |doi| DataciteService.delete_doi(doi: doi) }
    end
  end
end
