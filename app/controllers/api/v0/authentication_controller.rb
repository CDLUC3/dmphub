# frozen_string_literal: true

module Api
  module V0
    # Provides Authentication Services for the API
    #
    # Client Credentials:
    #  * NOTE: requires an entry in the `api_clients` table
    #
    #  POST Body must include the following JSON: {
    #    grant_type: 'client_credentials',
    #    client_id: '[api_client.client_id]',
    #    client_secret: '[api_client.client_secret]'
    #  }
    class AuthenticationController < BaseApiController
      respond_to :json

      skip_before_action :authorize_request, only: %i[authenticate]
      skip_before_action :check_agent, only: %i[authenticate]

      # POST /api/v1/authenticate
      def authenticate
        auth_svc = Api::V0::Auth::Jwt::AuthenticationService.new(json: auth_params.to_h)
        @token = auth_svc.call
        if @token.present?
          @expiration = auth_svc.expiration
          @token_type = 'Bearer'
          render '/api/v0/token', status: :ok
        else
          render_error errors: auth_svc.errors, status: :unauthorized
        end
      rescue JSON::ParserError => e
        Rails.logger.error "API V0 - authenticate: #{e.message}"
        Rails.logger.error request.body.read
        render_error errors: 'Missing or invalid JSON', status: :bad_request
      end

      private

      def auth_params
        params.permit(:grant_type, :client_id, :client_secret)
      end
    end
  end
end
