# frozen_string_literal: true

# A JSON representation of a Data Management Plan in the Common Standard format
# json.merge! model_json_base(model: data_management_plan)
json.title data_management_plan.title
json.created data_management_plan.created_at.utc.to_s
json.modified data_management_plan.updated_at.utc.to_s
json.description data_management_plan.description
json.language data_management_plan.language
json.ethical_issues_exist Api::V0::ConversionService.boolean_to_yes_no_unknown(data_management_plan.ethical_issues)
json.ethical_issues_description data_management_plan.ethical_issues_description
json.ethical_issues_report data_management_plan.ethical_issues_report

if data_management_plan.identifiers.any?
  json.dmp_id do
    # TODO: We should use a presenter to determine which Id to use (e.g. DOI first)
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: data_management_plan.identifiers.first
  end
end

if data_management_plan.primary_contact.present?
  json.contact do
    json.partial! 'api/v0/rda_common_standard/persons_show',
                  person: data_management_plan.primary_contact.person, rel: 'primary_contact'
  end
end

if data_management_plan.persons.any?
  json.contributor data_management_plan.persons do |pdmp|
    json.partial! 'api/v0/rda_common_standard/persons_show',
                  person: pdmp.person, rel: pdmp.role
  end
end

if data_management_plan.costs.any?
  json.cost data_management_plan.costs do |cost|
    json.partial! 'api/v0/rda_common_standard/costs_show', cost: cost
  end
end

json.project do
  json.partial! 'api/v0/rda_common_standard/projects_show',
                project: data_management_plan.project
end

json.dataset data_management_plan.datasets do |dataset|
  json.partial! 'api/v0/rda_common_standard/datasets_show', dataset: dataset
end
