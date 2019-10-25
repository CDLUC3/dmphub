# frozen_string_literal: true

module Rda
  # Service to convert RDA JSON into Models
  class JsonConverterService

    def initialize(json:)
      @json = json || {}
    end

    def dmp

    end

    def project
      return nil unless @json['project']

      project = Project.new(
        title:
      )
    end

    def costs

    end

    def persons

    end

    def datasets

    end

    private

    def awards

    end

  end
end
