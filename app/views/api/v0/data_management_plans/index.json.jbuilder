# frozen_string_literal: true

response_layout(json: json, caller: caller, source: source)

json.content do
  json.dmps  do
    json.array! data_management_plans.each do |dmp|
      doi = dmp.doi
      next unless doi.present?

      json.uri api_v0_data_management_plan_url(doi).gsub(/%2F/, '/')
      json.title dmp.title
      json.contact dmp.primary_contact #dmp.primary_contact.person.email
      json.created dmp.created_at.to_s
      json.modified dmp.updated_at.to_s
      json.authors dmp.authors
    end
  end
end
