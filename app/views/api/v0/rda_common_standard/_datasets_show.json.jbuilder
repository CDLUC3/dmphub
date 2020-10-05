# frozen_string_literal: true

# A JSON representation of a Dataset in the Common Standard format
# json.merge! model_json_base(model: dataset, skip_hateoas: true)
json.title dataset.title
json.description dataset.description
json.type dataset.dataset_type
json.language dataset.language
json.issued dataset.publication_date&.to_formatted_s(:iso8601) unless dataset.publication_date.nil?
json.personal_data Api::V0::ConversionService.boolean_to_yes_no_unknown(dataset.personal_data)
json.sensitive_data Api::V0::ConversionService.boolean_to_yes_no_unknown(dataset.sensitive_data)
json.data_quality_assurance dataset.data_quality_assurance
json.preservation_statement dataset.preservation_statement

if dataset.identifiers.any?
  # TODO: We should introduce a presenter that looks for the most appropriate
  #       identifier in these situation (e.g. DOI first, URL last)
  json.dataset_id do
    json.partial! 'api/v0/rda_common_standard/identifiers_show',
                  identifier: dataset.identifiers.first
  end
end

if dataset.keywords.any?
  json.keyword do
    json.array! dataset.keywords.collect(&:value)
  end
end

if dataset.security_privacy_statements.any?
  json.security_and_privacy dataset.security_privacy_statements do |security_privacy_statement|
    json.partial! 'api/v0/rda_common_standard/security_privacy_statements_show',
                  security_privacy_statement: security_privacy_statement
  end
end

if dataset.technical_resources.any?
  json.technical_resource dataset.technical_resources do |technical_resource|
    json.partial! 'api/v0/rda_common_standard/technical_resources_show',
                  technical_resource: technical_resource
  end
end

if dataset.distributions.any?
  json.distribution dataset.distributions do |distribution|
    json.partial! 'api/v0/rda_common_standard/distributions_show',
                  distribution: distribution
  end
end

if dataset.metadata.any?
  json.metadata dataset.metadata do |metadatum|
    json.partial! 'api/v0/rda_common_standard/metadata_show', metadatum: metadatum
  end
end
