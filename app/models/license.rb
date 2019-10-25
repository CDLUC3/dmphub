# frozen_string_literal: true

# A Dataset Distribution License
class License < ApplicationRecord
  # Associations
  belongs_to :distribution, optional: true

  # Validations
  validates :license_uri, :start_date, presence: true

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json(json:, provenance:, distribution: nil)
      return nil unless json.present? && provenance.present? &&
                        json['licenseRef'].present? && json['startDate'].present?

      json = json.with_indifferent_access
      license = find_or_initialize_by(license_uri: json['licenseRef'], distribution: distribution)
      license.start_date = json.fetch('startDate', Time.now.to_s)
      license
    end
  end
end
