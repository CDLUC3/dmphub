# frozen_string_literal: true

def mock_externals
  stub_request(:post, /https:\/\/ezid\.cdlib\.org\/shoulder\/doi:.*/).to_return(status: 201, body: "", headers: {})

  stub_request(:get, "api.ror.org").to_return(status: 200, body: "", headers: {})
  #stub_request(:get, "https://api.ror.org/organizations").to_return(status: 200, body: "", headers: {})
end
