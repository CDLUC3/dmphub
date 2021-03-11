# frozen_string_literal:  true

module Mocks
  # Module for mocking result from the EZID API
  # Using the top 3 results from: https://api.ror.org/organizations?query=Berkeley
  module Ezid
    def mock_ezid_success
      stub_request(:post, %r{ezid\.cdlib\.org/shoulder/doi:})
        .to_return(status: 201, body: mock_ezid_response, headers: {})

      stub_request(:put, %r{ezid\.cdlib\.org/id/})
      .to_return(status: 200, body: mock_ezid_response, headers: {})
    end

    def mock_ezid_failure
      stub_request(:post, %r{ezid\.cdlib\.org/shoulder/doi:})
        .to_return(status: 400, body: mock_ezid_error, headers: {})
    end

    def mock_ezid_response
      ark = SecureRandom.uuid
      doi = SecureRandom.uuid
      "success: ark:#{ark} | doi:#{doi}"
    end

    def mock_ezid_error
      'error: bad request - no such identifier'
    end
  end
end
