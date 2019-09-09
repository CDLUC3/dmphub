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

# methods for use with JSON/View validation
def validate_base_json_elements(model:, rendered:)
  return false unless model.present? && rendered.present?
  validate_created_at_presence(model: model, rendered: rendered)
  validate_hateoas_presence(model: model, rendered: rendered)
end

def validate_created_at_presence(model:, rendered:)
  return false unless model.present? && rendered.present?
  expect(rendered['created_at']).to eql(model.created_at.to_s)
end

def validate_hateoas_presence(model:, rendered:)
  return false unless model.present? && rendered.present?
  href = "api_v1_#{model.class.name.underscore}_url"
  expect(@json['links'].present?).to eql(true)
  expect(@json['links'].first['rel']).to eql('self')
  expect(@json['links'].first['href']).to eql(Rails.application.routes.url_helpers.send(href, model.id))
end
