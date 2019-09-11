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

json.licenses distribution.licenses do |license|
  json.partial! 'api/v1/licenses/show', license: license
end
json.host [distribution.hosts.first] do |host|
  json.partial! 'api/v1/hosts/show', host: host
end
