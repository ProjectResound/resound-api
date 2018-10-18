# frozen_string_literal: true

# Verifies that we have a valid web token from Auth0
class JsonWebToken
  JWKS_CACHE_KEY = 'jwks_hash_keys'

  AUTH0_DOMAIN = "https://#{Rails.application.secrets.auth0_domain}/"

  def self.verify(token)
    JWT.decode(token, nil,
               true, # Verify the signature of this token
               algorithm: 'RS256',
               iss: AUTH0_DOMAIN,
               verify_iss: true,
               aud: Rails.application.secrets.auth0_api_audience,
               verify_aud: true) do |header|
      jwks_hash[header['kid']]
    end
  end

  def self.jwks_hash
    jwks_keys = Rails.cache.fetch(JWKS_CACHE_KEY, expires_in: 1.day) do
      Array(
        JSON.parse(
          Net::HTTP.get(URI("#{AUTH0_DOMAIN}.well-known/jwks.json"))
        )['keys']
      )
    end
    Hash[
          jwks_keys
          .map do |k|
            [
              k['kid'],
              OpenSSL::X509::Certificate.new(
                Base64.decode64(k['x5c'].first)
              ).public_key
            ]
          end
      ]
  end
end
