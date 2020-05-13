# frozen_string_literal: true

# locals: items

json.prettify!
json.ignore_nil!

json.application @application
json.status Rack::Utils::HTTP_STATUS_CODES[response.status]
json.code response.status
json.time Time.now.utc.to_s
json.caller @caller
json.source "#{request.method} #{request.url}"

# Pagination Links
if items.respond_to?(:total_count) && items.total_count.positive?
  json.page @page
  json.per_page @per_page
  json.total_items items.total_count

  # Prepare the base URL by removing the old pagination params
  json.prev prev_page_link(current_url: request.url) unless @page == 1
  json.next next_page_link(current_url: request.url) unless @page >= (items.total_count / @per_page)
end
