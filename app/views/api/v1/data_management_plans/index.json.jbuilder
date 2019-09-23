response_layout(json: json, caller: caller, source: source)

json.content do
  json.dmps  do
    json.array! data_management_plans.each do |dmp|
      doi = dmp.identifiers.where(category: 'doi').first
      next unless doi.present?

      json.uri api_v1_dataset_url(doi.value).gsub(/%2F/, '/')
      json.title dmp.title
      json.contact dmp.primary_contact.person.email
      json.created dmp.created_at.to_s
      json.modified dmp.updated_at.to_s
    end
  end
end
