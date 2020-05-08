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

  def errors
    licenses.each { |license| super.copy!(license.errors) }
    host.validate if host.present? # has_one relationship does not auto-validate
    super.copy!(host.errors) if host.present?
    super
  end

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json!(provenance:, json:, dataset:)
      return nil unless json.present? && provenance.present? && dataset.present?

      json = json.with_indifferent_access
      return nil unless json['title'].present?

      distro = Distribution.find_or_initialize_by(dataset: dataset, title: json['title']) unless distro.present?

      distro.description = json['description'] if json['description'].present?
      distro.format = json['format'] if json['format'].present?
      distro.byte_size = json['byteSize'] if json['byteSize'].present?
      distro.access_url = json['accessUrl'] if json['accessUrl'].present?
      distro.download_url = json['downloadUrl'] if json['downloadUrl'].present?
      distro.available_until = json['availableUntil'] if json['availableUntil'].present?
      distro.data_access = json.fetch('dataAccess', 'closed')

      json.fetch('licenses', []).each do |license|
        lcsn = License.from_json!(json: license, provenance: provenance, distribution: distro)
        distro.licenses << lcsn unless lcsn.nil? || distro.licenses.include?(lcsn)
      end

      distro.host = Host.from_json!(provenance: provenance, json: json['host'], distribution: distro)

      distro.save
      distro
    end

  end
end
