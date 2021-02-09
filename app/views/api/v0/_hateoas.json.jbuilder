# frozen_string_literal: true

# locals: dmp, client
doi = Api::V0::IdentifierPresenter.doi_without_host(doi: dmp.doi&.value)
doi = dmp.id unless doi.present?

links = [
  { get: api_v0_data_management_plan_url(id: doi) }
]
if client.present?
  links << { post: api_v0_data_management_plans_url } if client.can_create_data_management_plans?

  if client.name == dmp.provenance.name
    links << { put: api_v0_data_management_plan_url(id: doi) }
    links << { delete: api_v0_data_management_plan_url(id: doi) }
  end
end

json.links links
