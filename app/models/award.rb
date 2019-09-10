# frozen_string_literal: true

# A data management plan
class Award < ApplicationRecord

  include Identifiable

  enum status: %i[planned applied granted rejected]

  # Associations
  belongs_to :project

  # Validations
  validates :funder_uri, :status, presence: true

  # Scopes
  scope :from_json, ->(json, provenance) do
    return nil unless json.present?

    json = delete_base_json_elements(json)
    args = json.select do |k, v|
      !%w[person_data_management_plans data_management_plans projects identifiers mbox].include?(k)
    end
    award = new(args)

    provenance = provenance || Rails.application.name.downcase
    award.identifiers << Identifier.new(category: 'email', value: json['mbox'], provenance: provenance)
    award.identifiers << json['identifiers'].map { |i| Identifier.from_json(i) }
    award
  end
end
