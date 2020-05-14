# frozen_string_literal: true

json.partial! 'api/v0/standard_response', items: [@dmp]

json.items 1.times do
  json.dmp do
    json.schema 'https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard/tree/master/examples/JSON/JSON-schema/1.0'
    json.partial! 'api/v0/rda_common_standard/data_management_plans_show',
                  data_management_plan: @dmp
  end
end
