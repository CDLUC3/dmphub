json.generation_date Time.now.to_s
json.source api_v1_data_management_plans_url

json.content do
  json.data_management_plans  do
    json.array! data_management_plans.each do |dmp|
      json.partial! 'api/v1/rda_common_standard/data_management_plans_show',
        data_management_plan: dmp
    end
  end
end
