# frozen_string_literal: true

json.partial! 'api/v0/standard_response', items: [@dmp]

# rubocop:disable Lint/UselessTimes
# Skipping rubocop check here because we need it to be an Array otherwise jbuilder creates a Hash
json.items 1.times do
  json.dmp do
    json.schema 'https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard/tree/master/examples/JSON/JSON-schema/1.0'
    json.partial! 'api/v0/rda_common_standard/data_management_plans_show',
                  data_management_plan: @dmp, client: @client
  end
end
# rubocop:enable Lint/UselessTimes
