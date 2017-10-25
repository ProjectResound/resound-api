module Api::V1
  class UsersController < BaseController
    include Secured

    def create
      profile = JWT.decode(JSON.parse(request.body.read)['idToken'], nil, false)[0]
      raise "Could not create a user" if profile.nil?

      if profile['nickname']
          User.find_or_create_by_uid(uid: profile['sub'], nickname: profile['nickname'])
          render status: :ok
      else
        raise "Could not create a user without a nickname"
      end
    end
  end
end
