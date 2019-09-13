json.generation_date Time.now.to_s
json.caller caller
json.source source

json.content do
  json.dmp do
    json.partial! 'api/v1/rda_common_standard/data_management_plans_show',
        data_management_plan: data_management_plan
  end
end