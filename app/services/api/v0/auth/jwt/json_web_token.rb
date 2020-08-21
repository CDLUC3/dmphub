# frozen_string_literal: true

module Api
  module V0
    module Auth
      module Jwt
        # Wrapper for JWT
        class JsonWebToken
          class << self
            def encode(payload:, exp: 24.hours.from_now)
              payload[:exp] = exp.to_i
              JWT.encode(payload, Rails.application.credentials.secret_key_base)
            rescue JWT::EncodeError
              nil
            end

            def decode(token:)
              body = JWT.decode(token,
                                Rails.application.credentials.secret_key_base)[0]
              HashWithIndifferentAccess.new body
            rescue JWT::ExpiredSignature => e
              raise e
            rescue JWT::DecodeError
              nil
            end
          end
        end
      end
    end
  end
end
