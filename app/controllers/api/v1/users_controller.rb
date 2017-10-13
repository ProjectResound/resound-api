module Api::V1
  class UsersController < BaseController
    include Secured

    def create
      if profile = JWT.decode(JSON.parse(request.body.read)['idToken'], nil, false)[0]
        if profile['nickname']
          User.find_or_create_by(uid: profile['sub']) do |user|
            user.nickname = profile['nickname']
          end
          render status: :ok
        else
          raise "Could not create a user without a nickname"
        end
      else
        raise "Could not create a user"
      end
    end
  end
end
