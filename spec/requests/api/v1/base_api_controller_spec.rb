# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BaseApiController, type: :request do
  before(:each) do
    doorkeeper_application = create(:doorkeeper_application, redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')

    @params = {
      client_id: doorkeeper_application.uid,
      client_secret: doorkeeper_application.secret,
      grant_type: 'client_credentials'
    }
  end

  describe :oauth_token do
    it 'returns a 401 (unauthorized) when credentials are missing' do
      @params.delete :client_id
      post oauth_token_path, params: @params, headers: token_headers
      expect(response.status).to eql(401)
    end

    it 'returns a 401 (unauthorized) for an unknown client_id' do
      @params[:client_id] = 'foo'
      post oauth_token_path, params: @params, headers: token_headers
      expect(response.status).to eql(401)
    end

    it 'returns a 401 (unauthorized) for an unknown client_secret' do
      @params[:client_secret] = 'foo'
      post oauth_token_path, params: @params, headers: token_headers
      expect(response.status).to eql(401)
    end

    it 'issues an access token when the client and user are both valid' do
      post oauth_token_path, params: @params, headers: token_headers
      expect(response.status).to eql(200)
      body_to_json
      expect(@json['access_token'].present?).to eql(true)
      expect(@json['token_type']).to eql('Bearer')
      expect([7199, 7200, 7201].include?(@json['expires_in'].to_i)).to eql(true)
      expect(@json['created_at'].present?).to eql(true)
    end
  end

  describe :base_json_response do
    it 'contains the right information' do
      get api_v1_heartbeat_path, headers: default_headers
      json = body_to_json
      expect(json['status']).to eql('ok')
      expect(json['application']).to eql(Rails.application.class.name)
    end
  end

  describe :unsecured_endpoint do
    it 'can be accessed when user is not authenticated' do
      get api_v1_heartbeat_path, headers: default_headers
      expect(body_to_json['status']).to eql('ok')
    end

    it 'can be accessed when user is authenticated' do
      get api_v1_heartbeat_path, headers: default_headers
      expect(body_to_json['status']).to eql('ok')
    end
  end

  describe :secured_endpoint do
    it 'cannot be access by an unathenticated user' do
      get api_v1_me_path, headers: default_headers
      expect(response.status).to eql(401)
    end

    it 'can be accessed by an authenticated user' do
      @doorkeeper_application = create(:doorkeeper_application)
      auth = setup_access_token(doorkeeper_application: @doorkeeper_application)
      get api_v1_me_path, headers: default_authenticated_headers(authorization: auth)
      expect(response.status).to eql(200)
      json = body_to_json
      expect(json[:uid]).to eql(@doorkeeper_application.uid)
      expect(json[:name]).to eql(@doorkeeper_application.name)
      expect(json[:redirect_uri]).to eql(@doorkeeper_application.redirect_uri)
      expect(json[:created_at]).to eql(@doorkeeper_application.created_at.to_s)
    end
  end

end
