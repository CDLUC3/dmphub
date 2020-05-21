# frozen_string_literal: true

json.partial! 'api/v0/standard_response', items: @awards

json.items @awards.each do |award|
  json.funding do
    json.dmpDOI award.project.data_management_plans.first.dois.first

    project = award.project
    json.projectTitle project.title
    json.projectStartOn project.start_on.utc.to_s
    json.projectEndOn project.end_on.utc.to_s

    auths = award.project.data_management_plans.first.person_data_management_plans.map do |pdmp|
      person = pdmp.person
      "#{person.name}#{person.organizations.any? ? "|#{person.organizations.first.name}" : ''}"
    end
    json.authors auths

    json.update_url Rails.application.routes.url_helpers.api_v0_award_url(award)
    json.partial! 'api/v0/rda_common_standard/awards_show', award: award
  end
end
