# frozen_string_literal: true

response_layout(json: json, caller: caller, source: source)

json.errors do
  json.array! errors
end
