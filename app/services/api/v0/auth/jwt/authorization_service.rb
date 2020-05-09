# frozen_string_literal: true

module Api
  module V0
    module Auth
      module Jwt
        # Service that Authorizes JWT and returns the ApiClient
        class AuthorizationService
          def initialize(headers: {})
            @headers = headers.nil? ? {} : headers
            @errors = HashWithIndifferentAccess.new
          end

          def call
            client
          end

          attr_reader :errors

          private

          # Lookup the Client bassed on the client_id embedded in the JWT
          def client
            return @api_client if @api_client.present?

            token = decoded_auth_token
            # If the token is missing or invalid then set the client to nil
            errors[:token] = 'Invalid token' unless token.present?
            return nil unless token.present? && token[:client_id].present?

            ApiClient.where(client_id: token[:client_id]).first
          end

          def decoded_auth_token
            return @token if @token.present?

            @token = JsonWebToken.decode(token: http_auth_header)
            @token
          rescue JWT::ExpiredSignature
            errors[:token] = 'Token expired'
            nil
          end

          # Extract the token from the Authorization header
          def http_auth_header
            hdr = @headers[:Authorization]
            errors[:token] = 'Missing token' unless hdr.present?
            return nil unless hdr.present?

            hdr.split.last
          end
        end
      end
    end
  end
end
