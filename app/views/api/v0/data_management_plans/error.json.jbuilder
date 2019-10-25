# frozen_string_literal: true

json.application @application
json.status @status
json.source @source
json.caller @caller
json.time Time.now.utc.to_s

json.total_items @payload[:total_items]
json.items @payload[:items]
json.errors @payload[:errors]
