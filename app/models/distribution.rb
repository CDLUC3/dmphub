# frozen_string_literal: true

# A Dataset Distribution
class Distribution < ApplicationRecord
  enum data_access: %i[closed open shared]

  # Associations
  belongs_to :dataset, optional: true
  has_one :host, dependent: :destroy
  has_many :licenses, dependent: :destroy

  # Validations
  validates :title, presence: true

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, dataset: nil)
      return nil unless json.present? && provenance.present? && json['title'].present?

      json = json.with_indifferent_access
      distribution = find_or_initialize_by(dataset: dataset, title: json['title'])

      distribution.description = json['description']
      distribution.format = json['format']
      distribution.byte_size = json['byteSize']
      distribution.access_url = json['accessUrl']
      distribution.download_url = json['downloadUrl']
      distribution.available_until = json['availableUntil']
      distribution.data_access = json.fetch('dataAccess', 'closed')

      json.fetch('licenses', []).each do |license|
        lcsn = License.from_json(json: license, provenance: provenance, distribution: distribution)
        distribution.licenses << lcsn unless distribution.licenses.include?(lcsn)
      end
      return distribution unless json['host'].present?

      distribution.host = Host.from_json(json: json['host'], provenance: provenance, distribution: distribution)
      distribution
    end
  end
end
