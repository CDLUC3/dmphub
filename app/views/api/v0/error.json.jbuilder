# frozen_string_literal: true

json.partial! 'api/v0/standard_response', items: []
json.errors @payload[:errors]
