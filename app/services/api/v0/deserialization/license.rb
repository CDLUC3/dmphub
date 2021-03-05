# frozen_string_literal: true

module Api
  module V0
    module Deserialization
      # Convert JSON into a License
      class License
        class << self
          # Convert incoming JSON into a License
          #    {
          #      "license_ref": "https://creativecommons.org/licenses/by/4.0/",
          #      "start_date": "2019-06-30"
          #    }
          def deserialize(provenance:, distribution:, json: {})
            return nil unless provenance.present? && distribution.present? && valid?(json: json)

            license = ::License.find_or_initialize_by(start_date: json[:start_date],
                                                      distribution: distribution)
            license.provenance = provenance unless license.provenance.present?
            license.license_ref = json[:license_ref]
            license
          end

          private

          # The JSON is valid if the License has a license_ref and start_date
          def valid?(json: {})
            json.present? && json[:license_ref].present? && json[:start_date].present?
          end
        end
      end
    end
  end
end
