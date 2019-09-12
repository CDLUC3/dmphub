# frozen_string_literal: true

# A JSON representation of a Dataset in the Common Standard format
json.merge! model_json_base(model: dataset)
json.title dataset.title
json.description dataset.description
json.type dataset.dataset_type
json.language dataset.language
json.issued dataset.publication_date.to_s
json.personal_data ConversionService.boolean_to_yes_no_unknown(dataset.personal_data)
json.sensitive_data ConversionService.boolean_to_yes_no_unknown(dataset.sensitive_data)
json.data_quality_assurance dataset.data_quality_assurance
json.preservation_statement dataset.preservation_statement

json.dataset_ids dataset.identifiers do |identifier|
  json.partial! 'api/v1/rda_common_standard/identifiers_show',
    identifier: identifier
end

json.keywords do
  json.array! dataset.keywords.collect { |k| k.value }
end

json.security_and_privacy_statements dataset.security_privacy_statements do |security_privacy_statement|
  json.partial! 'api/v1/rda_common_standard/security_privacy_statements_show',
    security_privacy_statement: security_privacy_statement
end

json.technical_resources dataset.technical_resources do |technical_resource|
  json.partial! 'api/v1/rda_common_standard/technical_resources_show',
    technical_resource: technical_resource
end

json.distributions dataset.distributions do |distribution|
  json.partial! 'api/v1/rda_common_standard/distributions_show',
    distribution: distribution
end

json.metadata dataset.metadata do |metadatum|
  json.partial! 'api/v1/rda_common_standard/metadata_show', metadatum: metadatum
end
