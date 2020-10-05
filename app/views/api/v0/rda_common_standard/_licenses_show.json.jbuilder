# frozen_string_literal: true

# A JSON representation of a Dsitribution License in the Common Standard format
json.license_ref license.license_ref
json.start_date license.start_date&.to_formatted_s(:iso8601)
