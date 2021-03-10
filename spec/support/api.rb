# frozen_string_literal: true

def mock_access_token(client:)
  payload = {
    grant_type: 'client_credentials',
    client_id: client.client_id,
    client_secret: client.client_secret
  }
  Api::V0::Auth::Jwt::JsonWebToken.encode(payload: payload)
end

def hash_to_json(hash:)
  JSON.parse(hash.to_json)
end

# Parse response body as json
def body_to_json
  @json = JSON.parse(@response.body)
  @json = @json.with_indifferent_access if @response.body && @json != [{}]
end

def default_headers
  { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
end

def default_authenticated_headers(client:, token: mock_access_token(client: client))
  default_headers.merge(
    'User-Agent': "#{client.name} (#{client.client_id})",
    Authorization: token
  )
end

def validate_base_response(json:)
  return false unless json.present?

  expect(json['application'].present?).to eql(true), 'expected to find `application`'
  expect(json['status'].present?).to eql(true), 'expected to find `status`'
  expect(json['code'].present?).to eql(true), 'expected to find `code`'
  expect(json['time'].present?).to eql(true), 'expected to find `time`'
  expect(json['caller'].present?).to eql(true), 'expected to find `caller`'
  expect(json['source'].present?).to eql(true), 'expected to find `source`'
  expect(json['items'].present?).to eql(true), 'expected to find `items`'
  true
end

def validate_pagination(json:)
  return false unless json.present?

  expect(json['page'].present?).to eql(true), 'expected to find `page`'
  expect(json['per_page'].present?).to eql(true), 'expected to find `per_page`'
  expect(json['total_items'].present?).to eql(true), 'expected to find `total_items`'
  first_page = json['page'] == 1
  last_page = json['page'] >= (json['total_items'] / json['per_page'])
  expect(json['prev'].present?).to eql(true), 'expected to find `prev`' unless first_page
  expect(json['next'].present?).to eql(true), 'expected to find `next`' unless last_page
end
