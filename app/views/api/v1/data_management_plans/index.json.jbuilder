json.generation_date Time.now.to_s
json.caller caller
json.source source

json.content do
  json.dmps  do
    json.array! data_management_plans.each do |dmp|
      json.partial! 'api/v1/rda_common_standard/data_management_plans_show',
        data_management_plan: dmp
    end
  end
end
