# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      include Secured

      def create
        profile = JWT.decode(
          JSON.parse(request.body.read)['idToken'], nil, false
        )[0]
        raise 'Could not create a user' if profile.nil?

        raise 'Could not create a user without a nickname' unless
          profile['nickname']

        User.find_or_create_by_uid(
          uid: profile['sub'], nickname: profile['nickname']
        )
        render status: :ok
      end
    end
  end
end
