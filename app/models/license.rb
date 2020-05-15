# frozen_string_literal: true

# A Dataset Distribution License
class License < ApplicationRecord
  include Authorizable

  # Associations
  belongs_to :distribution, optional: true

  # Validations
  validates :license_uri, :start_date, presence: true

  # Scopes
  class << self
    # Common Standard JSON to an instance of this object
    def from_json!(provenance:, json:, distribution:)
      return nil unless json.present? && provenance.present? && distribution.present?

      json = json.with_indifferent_access
      return nil unless json['licenseRef'].present?

      license = find_or_initialize_by(distribution: distribution, license_uri: json['licenseRef'])
      license.start_date = json.fetch('startDate', Time.now.to_s)
      license.save
      license
    end
  end
end
