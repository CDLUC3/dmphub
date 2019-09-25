# frozen_string_literal: true

response_layout(json: json, caller: caller, source: source)

json.content do
  json.dmp do
    json.partial! 'api/v1/rda_common_standard/data_management_plans_show',
                  data_management_plan: data_management_plan
  end
end
