# frozen_string_literal: true

json.partial! 'api/v0/standard_response', items: @payload[:items]

json.items data_management_plans.each do |dmp|
  json.dmp do
    doi = dmp.dois.first
    next unless doi.present?

    json.uri api_v0_data_management_plan_url(doi).gsub(/%2F/, '/')
    json.title dmp.title
    json.contact dmp.primary_contact # dmp.primary_contact.person.email
    json.created dmp.created_at.to_s
    json.modified dmp.updated_at.to_s
    json.authors dmp.authors
  end
end
