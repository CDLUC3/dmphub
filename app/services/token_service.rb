require 'digest'
require 'jwt'
require 'securerandom'

class TokenService

  class << self
    # Generate SHA256 hash
    def generate_digest(val)
      Digest::SHA256.hexdigest(val)
    end
    # Generate UUID
    def generate_uuid
      SecureRandom.uuid.split('-').join
    end
    # JWT encode
    def encode(payload)
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end
    # JWT decode
    def decode(token)
      HashWithIndifferentAccess.new(
        JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
      )
    rescue
      nil
    end
  end
end
