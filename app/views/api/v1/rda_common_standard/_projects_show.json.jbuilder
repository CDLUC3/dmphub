# frozen_string_literal: true

# A JSON representation of a Project in the Common Standard format
json.merge! model_json_base(model: project)
json.title project.title
json.description project.description
json.start_on project.start_on.to_s
json.end_on project.end_on.to_s

json.funding project.awards do |award|
  json.partial! 'api/v1/rda_common_standard/awards_show', award: award
end
