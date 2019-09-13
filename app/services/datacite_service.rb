# frozen_dtring_literal: true

class DataciteService

  SHOULDER = '10.80030'.freeze

  class << self

    def mint_doi(data_management_plan:)
      return "#{SHOULDER}/#{TokenService.generate_uuid}"
    end

  end

end
