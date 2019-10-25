# frozen_string_literal: true

json.ignore_nil!

# A JSON representation of a Dataset in the Common Standard format
#json.merge! model_json_base(model: dataset, skip_hateoas: true)
json.title dataset.title
json.description dataset.description
json.type dataset.dataset_type
json.language dataset.language
json.issued dataset.publication_date.to_s unless dataset.publication_date.nil?
json.personalData ConversionService.boolean_to_yes_no_unknown(dataset.personal_data)
json.sensitiveData ConversionService.boolean_to_yes_no_unknown(dataset.sensitive_data)
json.dataQualityAssurance dataset.data_quality_assurance
json.preservationStatement dataset.preservation_statement

if dataset.identifiers.any?
  json.datasetIds dataset.identifiers do |identifier|
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: identifier
  end
end

if dataset.keywords.any?
  json.keywords do
    json.array! dataset.keywords.collect(&:value)
  end
end

if dataset.security_privacy_statements.any?
  json.securityAndPrivacyStatements dataset.security_privacy_statements do |security_privacy_statement|
    json.partial! 'api/v0/rda_common_standard/security_privacy_statements_show',
                  security_privacy_statement: security_privacy_statement
  end
end

if dataset.technical_resources.any?
  json.technicalResources dataset.technical_resources do |technical_resource|
    json.partial! 'api/v0/rda_common_standard/technical_resources_show',
                  technical_resource: technical_resource
  end
end

if dataset.distributions.any?
  json.distributions dataset.distributions do |distribution|
    json.partial! 'api/v0/rda_common_standard/distributions_show',
                  distribution: distribution
  end
end

if dataset.metadata.any?
  json.metadata dataset.metadata do |metadatum|
    json.partial! 'api/v0/rda_common_standard/metadata_show', metadatum: metadatum
  end
end
