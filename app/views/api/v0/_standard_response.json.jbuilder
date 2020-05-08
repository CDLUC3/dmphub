# locals: items

# Retrieve the application name from the branding file or default to the
# application class name
app = Rails.configuration.branding.fetch(:application, {})
                                  .fetch(:name, Rails.application.class.name)

# Standard API response attributes and pagination URLs
json.application app
json.status Rack::Utils::HTTP_STATUS_CODES[response.status]
json.time Time.now.utc.to_s
json.caller @client.name
json.source "#{request.method} #{request.url}"

# Pagination Links
if items.respond_to?(:total_count) && items.total_count > 0
  json.page @page
  json.per_page @per_page
  json.total_items items.total_count

  # Prepare the base URL by removing the old pagination params
  json.prev prev_page_link(current_url: request.url) unless @page == 1
  json.next next_page_link(current_url: request.url) unless @page >= (items.total_count / @per_page)
end
