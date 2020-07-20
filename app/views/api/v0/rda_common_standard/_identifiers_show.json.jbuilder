# frozen_string_literal: true

# A JSON representation of an Identifier in the Common Standard format
unless identifier.present?
  json.type identifier.inspect # Api::V0::ConversionService.to_rda_identifier_category(category: identifier.category)
  json.identifier '' # identifier.value
end
