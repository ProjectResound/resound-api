module Secured
  require 'json_web_token'
  extend ActiveSupport::Concern
  USER_CACHE_KEY = 'user_cache'

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    if uid = auth_token['sub']
      @current_user = Rails.cache.read(cache_key(uid))
      if !@current_user
        @current_user = User.find_or_create_by(uid: uid) do |user|
          user.nickname = auth_token['nickname']
        end
        if !@current_user
          raise JWT::VerificationError
        end
        Rails.cache.write(cache_key(uid), @current_user, expires_in: 3.minutes)
      end
      # Multi-tenant switch. Assumes you've done a migration to add an apartment attribute on the user model.
      Apartment::Tenant.switch!(@current_user.apartment)
    else
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
    end
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  def cache_key(uid)
    "#{USER_CACHE_KEY}:#{uid}"
  end

  def http_token
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    end
  end

  def auth_token
    JsonWebToken.verify(http_token)[0]
  end
end