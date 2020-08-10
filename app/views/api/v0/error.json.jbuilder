# frozen_string_literal: true

json.partial! 'api/v0/standard_response', items: @payload[:items]
json.errors @payload[:errors]

if @payload.fetch(:items, []).any?
  json.items @payload[:items] do |identifier|
    json.dmp do
      json.dmp_id do
        json.partial! 'api/v0/rda_common_standard/identifiers_show', identifier: identifier
      end
    end
  end
end
