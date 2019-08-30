# frozen_string_literal: true

def mock_access_token(user:)
  setup_access_token(
    doorkeeper_application: create(:doorkeeper_application, redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'),
    user: user
  )
end

# Parse response body as json
def body_to_json
  @json = JSON.parse(@response.body).with_indifferent_access if @response.body.present?
end

def get_access_token(doorkeeper_application:, user:)
  params = {
    client_id: doorkeeper_application.uid,
    client_secret: doorkeeper_application.secret,
    grant_type: 'password',
    uid: user.id,
    secret: user.secret
  }
  post oauth_token_path, params: params, headers: @default_headers
  body_to_json[:access_token]
end

def setup_access_token(doorkeeper_application:, user:)
  @access_token = get_access_token(doorkeeper_application: doorkeeper_application, user: user)
end

def default_headers
  { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
end

def default_authenticated_headers
  default_headers.merge('Authorization' => "#{@token_type} #{@access_token}")
end
