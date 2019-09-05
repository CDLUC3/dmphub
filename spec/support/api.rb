# frozen_string_literal: true

def mock_access_token
  @doorkeeper_application = create(:doorkeeper_application)
  setup_access_token(
    doorkeeper_application: @doorkeeper_application
  )
end

# Parse response body as json
def body_to_json
  @json = JSON.parse(@response.body)
  @json = @json.with_indifferent_access if @response.body && @json != [{}]
end

def get_access_token(doorkeeper_application:)
  params = {
    client_id: doorkeeper_application.uid,
    client_secret: doorkeeper_application.secret,
    grant_type: 'client_credentials'
  }
  post oauth_token_path, params: params, headers: token_headers
  json = body_to_json
  "#{json[:token_type]} #{json[:access_token]}"
end

def setup_access_token(doorkeeper_application:)
  @access_token = get_access_token(doorkeeper_application: doorkeeper_application)
end

def token_headers
  { 'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8', 'Accept' => 'application/json' }
end

def default_headers
  { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
end

def default_authenticated_headers(authorization:)
  default_headers.merge('Authorization' => authorization.to_s)
end
