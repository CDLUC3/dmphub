# frozen_string_literal: true

# A JSON representation of a Dataset in the Common Standard format
json.merge! model_json_base(model: dataset)
json.title dataset.title
json.type dataset.dataset_type
json.personal_data dataset.has_personal_data?
json.sensitive_data dataset.has_sensitive_data?

json.identifiers dataset.identifiers do |identifier|
  json.partial! 'api/v1/identifiers/show', identifier: identifier
end

descriptions = dataset.descriptions
quality_assurances = descriptions.select{ |d| d.category == 'quality_assurance' }
preservation_statements = descriptions.select{ |d| d.category == 'preservation_statement' }
descriptions = (descriptions - quality_assurances) - preservation_statements

json.descriptions descriptions do |description|
  json.partial! 'api/v1/descriptions/show', description: description
end

json.data_quality_assurances quality_assurances do |description|
  json.partial! 'api/v1/descriptions/show', description: description
end
json.preservation_statements preservation_statements do |description|
  json.partial! 'api/v1/descriptions/show', description: description
end

# ToDo: Implement these later
json.keywords []
json.languages []
json.keywords []
json.issued []
