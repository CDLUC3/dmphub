# frozen_string_literal: true

# A JSON representation of a Project in the Common Standard format
json.merge! model_json_base(model: project)
json.title project.title

json.descriptions project.descriptions do |description|
  json.partial! 'api/v1/descriptions/show', description: description
end

json.funding project.awards do |award|
  json.partial! 'api/v1/awards/show', award: award
end
