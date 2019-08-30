# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BaseApiController, type: :request do

  before(:each) do
    @user = create(:user)

    doorkeeper_application = create(:doorkeeper_application, redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')

    @params = {
      client_id: doorkeeper_application.uid,
      client_secret: doorkeeper_application.secret,
      grant_type: 'password',
      uid: @user.id,
      secret: @user.secret
    }
  end

  describe :oauth_token do
    it 'returns a 400 (bad request) for an unknown user' do
      @params[:secret] = 'foo'
      post oauth_token_path, params: @params.to_json, headers: default_headers
      expect(response.status).to eql(400)
    end

    it 'returns a 401 (unauthorized) for an unknown client' do
      @params[:client_secret] = 'foo'
      post oauth_token_path, params: @params.to_json, headers: default_headers
      expect(response.status).to eql(401)
    end

    it 'issues an access token when the client and user are both valid' do
      post oauth_token_path, params: @params.to_json, headers: default_headers
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
      expect(body_to_json).to eql(nil)
    end

    it 'can be accessed by an authenticated user' do
      post oauth_token_path, params: @params.to_json, headers: default_headers
      @access_token = body_to_json['access_token']
      @token_type = body_to_json['token_type']
      get api_v1_me_path, headers: default_authenticated_headers
      expect(response.status).to eql(200)
      json = body_to_json
      expect(json[:id]).to eql(@user.id)
    end
  end

end
