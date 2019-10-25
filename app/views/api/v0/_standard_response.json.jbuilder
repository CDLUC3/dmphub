# locals: items

json.application @application
json.status @status
json.source @source
json.caller @caller
json.time Time.now.utc.to_s

json.total_items items.length
