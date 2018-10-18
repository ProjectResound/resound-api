# frozen_string_literal: true

module Secured
  require 'json_web_token'
  extend ActiveSupport::Concern
  USER_CACHE_KEY = 'user_cache'

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    if (uid = auth_token['sub'])
      @current_user = Rails.cache.read(cache_key(uid))
      unless @current_user
        @current_user = User.find_or_create_by(uid: uid) do |user|
          user.nickname = auth_token['nickname']
        end
        raise JWT::VerificationError unless @current_user

        Rails.cache.write(cache_key(uid), @current_user, expires_in: 3.minutes)
      end
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
    return unless request.headers['Authorization'].present?

    request.headers['Authorization'].split(' ').last
  end

  def auth_token
    JsonWebToken.verify(http_token)[0]
  end
end
