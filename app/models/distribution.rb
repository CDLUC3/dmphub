# frozen_string_literal: true

# A Dataset Distribution
class Distribution < ApplicationRecord

  enum data_access: %i[closed open shared]

  # Associations
  belongs_to :dataset, optional: true
  has_one :host
  has_many :licenses

  # Validations
  validates :title, presence: true

  # Scopes
  class << self

    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:)
      return nil unless json.present? && provenance.present? && json['title'].present?

      json = json.with_indifferent_access
      distribution = new(
        title: json['title'],
        description: json['description'],
        format: json['format'],
        byte_size: json['byte_size'],
        access_url: json['access_url'],
        download_url: json['download_url'],
        available_until: json['available_until'],
        data_access: json.fetch('data_access', 'closed')
      )

      json.fetch('licenses', []).each do |license|
        distribution.licenses << License.from_json(json: license, provenance: provenance)
      end
      return distribution unless json['host'].present?

      distribution.host = Host.from_json(json: json['host'], provenance: provenance)
      distribution
    end

  end
end
