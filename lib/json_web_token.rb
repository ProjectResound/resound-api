class JsonWebToken
  JWKS_RAW = Net::HTTP.get URI("https://#{Rails.application.secrets.auth0_domain}/.well-known/jwks.json")
  JWKS_KEYS = Array(JSON.parse(JWKS_RAW)['keys'])

  def self.verify(token)
    JWT.decode(token, nil,
               true, # Verify the signature of this token
               algorithm: 'RS256',
               iss: "https://#{Rails.application.secrets.auth0_domain}/",
               verify_iss: true,
               aud: Rails.application.secrets.auth0_api_audience,
               verify_aud: true) do |header|
      jwks_hash[header['kid']]
    end
  end

  def self.jwks_hash
    Hash[
        JWKS_KEYS
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