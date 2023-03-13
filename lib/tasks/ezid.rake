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

  desc 'Generates the EZID XML for specified Data Management Plan'
  task :xml, %i[data_management_plan_id] => [:environment] do |_t, args|
    if args.any? && args[:data_management_plan_id].present?
      dmp = DataManagementPlan.find_by(id: args.data_management_plan_id)

      if dmp.present?
        controller = ActionController::Base.new
        pp controller.render_to_string('ezid/minter.xml', locals: { data_management_plan: dmp })
      else
        p 'Could not find the specified DMP. We are looking for data_management_plan.id'
      end
    else
      p 'You must specify an ID retry with: `rails "ezid:xml[123]"`.'
    end
  end
end
