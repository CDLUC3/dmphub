# frozen_string_literal: true

json.application @application
json.status @status
json.source @source
json.caller @caller
json.time Time.now.utc.to_s

json.total_items 1

json.items 1.times do
  json.dmp do
    json.partial! 'api/v0/rda_common_standard/data_management_plans_show',
                  data_management_plan: @dmp
  end
end
