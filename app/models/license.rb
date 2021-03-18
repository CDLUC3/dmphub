# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id              :bigint           not null, primary key
#  distribution_id :bigint
#  license_ref     :string(255)      not null
#  start_date      :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  provenance_id   :bigint
#
# A Dataset Distribution License
class License < ApplicationRecord
  include Alterable
  include Authorizable

  # Associations
  belongs_to :distribution, optional: true

  # Validations
  validates :license_ref, :start_date, presence: true

  # Retrieve the :name of the license from the license_ref
  def display_name
    return license_ref unless license_ref.downcase.ends_with?('.json')

    Rails.cache.fetch("license/#{license_ref}/display_name", expires_in: 48.hours) do
      resp = HTTParty.get(license_ref, { headers: { Accept: 'application/json' }, follow_redirects: true })
      unless resp.present? && resp.code == 200
        Rails.logger.warn "License.display_name could not fetch #{license_ref} - HTTP #{resp.code}"
        return license_ref
      end

      JSON.parse(resp.body).fetch('name', license_ref)
    end
  rescue JSON::ParserError => e
    Rails.logger.error "License.display_name could not parse the JSON for #{license_ref}"
    license_ref
  end
end
