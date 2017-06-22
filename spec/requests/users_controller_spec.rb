describe Api::V1::UsersController do
  USERS_API_ENDPOINT = '/api/v1/users/'

  before(:each) do
    allow(Net::HTTP).to receive(:start).and_return(double())
    allow_any_instance_of(Api::V1::UsersController).to receive(:authenticate_request!).and_return(true)
  end

  describe 'CREATE' do
    context 'a new user' do
      it 'creates a new user' do
        nickname = 'jamie.bond'
        allow(JWT).to receive(:decode).and_return([{'sub' => 'auth0|someId123123', 'nickname' => nickname}])

        expect {
          post USERS_API_ENDPOINT, params: { idToken: 'idtoken' }.to_json
        }.to change{User.count}.by(1)

        expect(response.status).to eq 200
        expect(User.last.nickname).to eq nickname
      end
    end

    context 'a returning user' do
      it 'does not create a new user' do
        nickname = 'jamie.bond'
        uid = 'wah|123123'

        User.create(
                   uid: uid,
                   nickname: nickname)
        allow(JWT).to receive(:decode).and_return([{'sub' => uid, 'nickname' => nickname}])

        expect {
          post USERS_API_ENDPOINT, params: { idToken: 'idToken' }.to_json
        }.to change{User.count}.by(0)
      end
    end
  end
end