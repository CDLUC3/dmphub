# frozen_string_literal: true

# A data management plan
class Award < ApplicationRecord
  include Identifiable

  enum status: %i[planned applied granted rejected]

  # Associations
  belongs_to :project, optional: true

  accepts_nested_attributes_for :identifiers

  # Validations
  validates :funder_uri, :status, presence: true

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, project: nil)

p "JSON PRESENT? #{json.present?}"
p "PROV PRESENT? #{provenance.present?}"
p "FUNDER ID PRESENT? #{json['funder_id'].present?}"

      return nil unless json.present? && provenance.present? && json['funder_id'].present?

      json = json.with_indifferent_access
      award = find_or_initialize_by(project: project, funder_uri: json['funder_id'])
      award.status = json.fetch('funding_status', 'planned')
      return award unless json['grant_id'].present?

      # Convert the grant_id into an identifier record
      ident = {
        'category': 'url',
        'value': json['grant_id'],
        'descriptor': 'funded_by'
      }
      id = Identifier.from_json(json: ident, provenance: provenance)
      award.identifiers << id unless award.identifiers.include?(id)
      award
    end
  end
end
