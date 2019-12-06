# frozen_string_literal: true

json.ignore_nil!

# A JSON representation of a Project in the Common Standard format
#json.merge! model_json_base(model: project, skip_hateoas: true)
json.title project.title
json.description project.description
json.startOn project.start_on.to_s
json.endOn project.end_on.to_s

if project.awards.any?
  json.funding project.awards do |award|
    json.partial! 'api/v0/rda_common_standard/awards_show', award: award
  end
end