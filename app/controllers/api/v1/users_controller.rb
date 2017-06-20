module Api::V1
  class UsersController < BaseController
    include Secured

    def create
      if profile = JWT.decode(JSON.parse(request.body.read)['idToken'], nil, false)[0]
        User.find_or_create_by(uid: profile['sub']) do |user|
          user.nickname = profile['nickname']
        end
      end
      render status: :ok
    end
  end
end
