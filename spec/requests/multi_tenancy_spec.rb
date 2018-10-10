describe 'Multi Tenancy Behaviour based on subdomains' do
  before do
    Apartment::Tenant.create('kpcc')
    Apartment::Tenant.create('npr')

    allow_any_instance_of(Api::V1::ContributorsController).to receive(:authenticate_request!)
      .and_return(true)
    allow_any_instance_of(Api::V1::UsersController).to receive(:authenticate_request!)
      .and_return(true)
  end

  context 'creating a contributor' do
    let(:end_point) { '/api/v1/contributors/' }

    context "using kpcc.resound.npr.org as host" do
      it 'creates the contributor under kpcc tenant' do
        post end_point, params: { name: 'new_contributor' }, headers: { 'X-tenant' => 'kpcc'}

        Apartment::Tenant.switch! 'kpcc'
        contributor = Contributor.first

        expect(contributor.name).to eq 'new_contributor'

        Apartment::Tenant.switch! 'npr'

        expect(Contributor.count).to eq 0
      end
    end

    context "using npr.resound.npr.org as host" do
      it 'creates the contributor under npr tenant' do
        post end_point, params: { name: 'new_contributor' }, headers: { 'X-tenant' => 'npr'}

        Apartment::Tenant.switch! 'npr'
        contributor = Contributor.first

        expect(contributor.name).to eq 'new_contributor'

        Apartment::Tenant.switch! 'kpcc'

        expect(Contributor.count).to eq 0
      end
    end
  end

  context 'creating an user' do
    let(:end_point) { '/api/v1/users/' }
    let(:nickname) { 'john.doe' }

    before do
      allow(JWT).to receive(:decode).
        and_return([{'sub' => 'auth0|someId123123', 'nickname' => nickname}])
    end

    context "using kpcc.resound.npr.org as host" do
      it 'creates the user under kpcc tenant' do
        post end_point, params: { idToken: 'idtoken' }.to_json, headers: { 'X-tenant' => 'kpcc'}

        Apartment::Tenant.switch! 'kpcc'
        contributor = User.first

        expect(contributor.nickname).to eq nickname

        Apartment::Tenant.switch! 'npr'

        expect(User.count).to eq 0
      end
    end

    context "using npr.resound.npr.org as host" do
      before do
        host! 'npr.resound.npr.org'
      end

      it 'creates the contributor under npr tenant' do
        post end_point, params: { idToken: 'idtoken' }.to_json, headers: { 'X-tenant' => 'npr'}

        Apartment::Tenant.switch! 'npr'
        contributor = User.first

        expect(contributor.nickname).to eq nickname

        Apartment::Tenant.switch! 'kpcc'

        expect(User.count).to eq 0
      end
    end
  end
end
