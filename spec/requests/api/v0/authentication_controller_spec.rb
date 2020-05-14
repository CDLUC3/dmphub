# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::AuthenticationController, type: :request do
  before(:each) do
    @client = create(:api_client)
  end

  context 'actions' do
    describe 'POST /api/v0/authenticate' do
      before(:each) do
        @client = create(:api_client)
        @payload = {
          grant_type: 'client_credentials',
          client_id: @client.client_id,
          client_secret: @client.client_secret
        }
      end

      it 'renders /api/v0/error template if authentication fails' do
        errs = [Faker::Lorem.sentence]
        allow_any_instance_of(Api::V0::Auth::Jwt::AuthenticationService).to receive(:call).and_return(nil)
        allow_any_instance_of(Api::V0::Auth::Jwt::AuthenticationService).to receive(:errors).and_return(errs)
        post api_v0_authenticate_path, params: JSON.parse(@payload.to_json)
        expect(response.code).to eql('401')
        expect(response).to render_template('api/v0/error')
      end
      it 'returns a JSON Web Token' do
        token = Api::V0::Auth::Jwt::JsonWebToken.encode(payload: @payload)
        allow_any_instance_of(Api::V0::Auth::Jwt::AuthenticationService).to receive(:call).and_return(token)
        post api_v0_authenticate_path, params: JSON.parse(@payload.to_json)
        expect(response.code).to eql('200')
        expect(response).to render_template('api/v0/token')
      end
    end
  end
end
