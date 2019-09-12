json.generation_date Time.now.to_s
json.source api_v1_data_management_plan_url(data_management_plan.id)

json.content do
  json.data_management_plan do
    json.partial! 'api/v1/rda_common_standard/data_management_plans_show',
        data_management_plan: data_management_plan
  end
end