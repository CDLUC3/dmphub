response_layout(json: json, caller: caller, source: source)

json.errors do
  json.array! errors.collect { |err| err }
end