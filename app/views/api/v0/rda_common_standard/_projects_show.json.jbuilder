# frozen_string_literal: true

# A JSON representation of a Project in the Common Standard format
# json.merge! model_json_base(model: project, skip_hateoas: true)
json.title project.title
json.description project.description
json.start project.start_on&.to_formatted_s(:iso8601)
json.end project.end_on&.to_formatted_s(:iso8601)

if project.fundings.any?
  json.funding project.fundings do |funding|
    json.partial! 'api/v0/rda_common_standard/fundings_show', funding: funding
  end
end
