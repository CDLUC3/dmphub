# frozen_string_literal: true

json.partial! 'api/v0/standard_response', items: [@dmp]

# rubocop:disable Lint/UselessTimes
# Skipping rubocop check here because we need it to be an Array otherwise jbuilder creates a Hash
json.items [@dmp] do |dmp|
  json.dmp do
    json.schema 'https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard/tree/master/examples/JSON/JSON-schema/1.0'

    extensions = [
      { name: 'dmphub', uri: 'https://github.com/CDLUC3/dmphub-json-schema' },
      { name: 'dmproadmap', uri: 'https://github.com/DMPRoadmap/api-json-schema' }
    ]
    json.extensions extensions do |extension|
      json.name extension[:name]
      json.uri extension[:uri]
    end

    json.partial! 'api/v0/rda_common_standard/data_management_plans_show',
                  data_management_plan: dmp, client: @client
  end
end
# rubocop:enable Lint/UselessTimes
