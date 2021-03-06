# frozen_string_literal: true

# A JSON representation of an Identifier in the Common Standard format
if identifier.present?
  json.type Api::V0::ConversionService.to_rda_identifier_category(category: identifier.category)
  json.identifier identifier.value
  json.descriptor identifier.descriptor unless %w[is_funded_by is_identified_by].include?(identifier.descriptor)
end
