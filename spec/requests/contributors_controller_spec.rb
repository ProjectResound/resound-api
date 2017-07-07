describe Api::V1::ContributorsController do
  API_ENDPOINT = '/api/v1/contributors/'

  before(:each) do |example|
    @user = User.create(uid: '123', nickname: 'louise')

    allow(Net::HTTP).to receive(:start).and_return(double())
    unless example.metadata[:skip_auth]
      allow_any_instance_of(Api::V1::ContributorsController).to receive(:auth_token).and_return(
          {'sub' => @user.uid, 'nickname' => @user.nickname}
      )
    end
  end

  describe 'CREATE' do
    context 'when a contributor exists' do
      it 'does not create a new contributor and returns a 200' do
        name = 'Neville'
        contributor = Contributor.create(name: name)
        expect {
          post API_ENDPOINT, params: {name: contributor.name}
        }.to_not change{Contributor.count}

        expect(response.status).to eq 204
      end
    end

    context 'when a contributor does not exist' do
      it 'creates contributor and returns a 201' do
        name = 'hermione granger'
        expect {
          post API_ENDPOINT, params: {name: name}
        }.to change{Contributor.count}.by(1)

        expect(response.status).to eq 201
        expect(json['name']).to eq name
      end
    end
  end

  describe 'GET' do
    context 'when unauthorized' do
      it 'returns 401', skip_auth: true do
        get API_ENDPOINT, params: {name: 'something'}
        expect(response.status).to eq(401)
      end
    end
    context 'when a contributor exists' do
      it 'returns a list of matching contributors' do
        Contributor.create(name: 'Ginny Weasley')
        Contributor.create(name: 'Ginny Tonic')
        get API_ENDPOINT, params: {name: 'ginny'}

        expect(json.size).to eq 2
        expect(json[0]['name']).to match('ginny')
        expect(json[1]['name']).to match('ginny')
      end
    end
    context 'when a contributor does not exist' do
      it 'returns an empty list' do
        get API_ENDPOINT, params: {name: 'santa claus'}
        expect(json.size).to eq 0
      end
    end
    context 'when requesting a whole list' do
      it 'returns all contributors' do
        Contributor.create(name: 'Blinky')
        Contributor.create(name: 'Inky')
        Contributor.create(name: 'Pinky')
        Contributor.create(name: 'Clyde')

        get API_ENDPOINT
        expect(json.size).to eq 4
      end
    end
  end
end
