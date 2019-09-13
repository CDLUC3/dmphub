# frozen_string_literal: true

# A JSON representation of a Dataset Distribution in the Common Standard format
json.merge! model_json_base(model: distribution, skip_hateoas: true)
json.title distribution.title
json.description distribution.description
json.format distribution.format
json.byte_size distribution.byte_size
json.access_url distribution.access_url
json.download_url distribution.download_url
json.data_access distribution.data_access
json.available_until distribution.available_until.to_s

if distribution.licenses.any?
  json.licenses distribution.licenses do |license|
    json.partial! 'api/v1/rda_common_standard/licenses_show', license: license
  end
end

if distribution.host.present?
  json.host do
    json.partial! 'api/v1/rda_common_standard/hosts_show', host: distribution.host
  end
end
