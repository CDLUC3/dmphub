# frozen_string_literal: true

# A JSON representation of a Data Management Plan in the Common Standard format
json.merge! model_json_base(model: data_management_plan)
json.title data_management_plan.title
json.language data_management_plan.language
json.ethical_issues_exist data_management_plan.has_ethical_issues?

json.dmp_ids data_management_plan.identifiers do |identifier|
  json.partial! 'api/v1/identifiers/show', identifier: identifier
end

descriptions = data_management_plan.descriptions.select { |d| d.category != 'ethical_issue' }
ethical_issue_descriptions = data_management_plan.descriptions.select { |d| d.category == 'ethical_issue' }

json.descriptions descriptions do |description|
  json.partial! 'api/v1/descriptions/show', description: description
end

json.ethical_issue_descriptions ethical_issue_descriptions do |description|
  json.partial! 'api/v1/descriptions/show', description: description
end

json.ethical_issue_reports []

json.contact [data_management_plan.primary_contact] do |person|
  json.partial! 'api/v1/persons/show', person: person.person, rel: 'primary_contact'
end

json.dm_staff data_management_plan.persons do |person|
  json.partial! 'api/v1/persons/show', person: person.person, rel: person.role
end

json.project [data_management_plan.project] do |project|
  json.partial! 'api/v1/projects/show', project: project
end

json.datasets data_management_plan.datasets do |dataset|
  json.partial! 'api/v1/datasets/show', dataset: dataset
end
