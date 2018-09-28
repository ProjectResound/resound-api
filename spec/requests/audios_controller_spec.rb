describe Api::V1::AudiosController do
  AUDIO_API_ENDPOINT = '/api/v1/audios/'
  let(:uploader) { FactoryBot.create(:user, uid: '123', nickname: 'louise') }

  before(:each) do |example|
    allow(Net::HTTP).to receive(:start).and_return(double())

    unless example.metadata[:skip_auth]
      allow_any_instance_of(Api::V1::AudiosController).to receive(:auth_token).and_return(
          {'sub' => uploader.uid, 'nickname' => uploader.nickname}
      )
    end
  end

  describe 'CREATE' do
    context 'a non-last chunk is received' do
      it 'does not combine all the chunks' do
        test_file = 'test.wav'
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', test_file), 'audio/wav')
        allow(Dir).to receive(:[]).and_return(['chunk_file_directory/lalala1.wav.part1', 'chunk_file_directory/lalala2.wav.part2'])

        post AUDIO_API_ENDPOINT, params: {file: file,
                                          flowTotalChunks: 10,
                                          flowIdentifier: '123-lalala1' }

        expect(response.status).to eq 200
      end
    end

    context 'a last chunk is received' do
      before(:each) do
        allow(File).to receive(:size)
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:open).and_call_original
        allow(File).to receive(:open).with('tmp/final/lalala.wav.flac')
      end

      ActiveJob::Base.queue_adapter = :test
      test_file = 'test.wav'
      file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', test_file), 'audio/wav')

      filename = 'lalala.wav'

      it 'enqueues a job and creates a new audio object' do
        expect {
        post AUDIO_API_ENDPOINT, params: {file: file,
                                          flowTotalChunks: 2,
                                          flowIdentifier: '123-lalala1',
                                          flowFilename: filename,
                                          title: 'lalad',
                                          contributors: 'ben stein'}
        }.to have_enqueued_job(AudioProcessing)

        audio = Audio.by_filename(filename).first

        expect(audio.filename).to eq(filename)
        expect(audio.contributors).to eq('ben stein')
      end

      it 'updates the non-unique fields' do
        changed_contributor = 'ben stein'
        changed_title = 'lalad'

        post AUDIO_API_ENDPOINT, params: {file: file,
                                          flowTotalChunks: 2,
                                          flowIdentifier: '123-lalala1',
                                          flowFilename: filename,
                                          title: 'title',
                                          contributors: 'contributor'}

        expect {
          post AUDIO_API_ENDPOINT, params: {file: file,
                                            flowTotalChunks: 2,
                                            flowIdentifier: '123-lalala1',
                                            flowFilename: filename,
                                            title: changed_title,
                                            contributors: changed_contributor}
        }.to have_enqueued_job(AudioProcessing)

        audio = Audio.by_filename(filename).first

        expect(audio.title).to eq(changed_title)
        expect(audio.contributors).to eq(changed_contributor)

      end

      it "updates existing audio's filename instead of creating a new audio" do
        og_filename = 'originalfile.wav'
        new_filename = 'new_filename.wav'
        audio = FactoryBot.create(
            :audio,
            title: 'no hiking for me',
            filename: og_filename,
            uploader: uploader
        )

        expect{
          post AUDIO_API_ENDPOINT, params: {file: file,
                                          flowTotalChunks: 2,
                                          flowIdentifier: '123-lalala1',
                                          flowFilename: new_filename,
                                          title: 'title',
                                          contributors: 'contributor',
                                          originalFilename: og_filename
                                          }
        }.not_to change{Audio.count}

        audio.reload

        expect(audio.filename).to eq(new_filename)
      end

    end
  end

  describe 'INDEX' do
    context 'unauthorized' do
      it 'returns 401', skip_auth: true do
        get AUDIO_API_ENDPOINT, params: {filename: 'something'}

        expect(response.status).to eq(401)
      end
    end

    context 'it matches an object' do
      it 'returns an audio object' do
        audio = FactoryBot.create(
          :audio,
          title: 'title mcTitle',
          filename: 'filename',
          uploader: uploader
        )

        get AUDIO_API_ENDPOINT, params: {filename: audio.filename}

        expect(response.status).to eq 200
        expect(json['audios'][0]['title']).to eq(audio.title)
      end
    end
    context 'there is no object' do
      it 'returns nothing' do
        audio = Audio.new

        get AUDIO_API_ENDPOINT, params: {filename: audio.filename}

        expect(response.status).to eq 200
        expect(json['totalPages']).to eq 0
      end
    end

    context 'user_id is passed in' do
      let(:uploader2) { FactoryBot.create(:user, uid: 'uid2', nickname: 'some other person') }

      it 'returns 3 recent audios from that user' do
        FactoryBot.create_list(:audio, 3, uploader: uploader)
        FactoryBot.create(:audio, uploader: uploader2)

        get AUDIO_API_ENDPOINT, params: { working_on: true }

        expect(response.status).to eq 200
        expect(json['totalCount']).to eq 3
      end

      context 'user has not uploaded anything' do
        it 'returns empty array' do
          get AUDIO_API_ENDPOINT, params: { working_on: true }

          expect(response.status).to eq 200
          expect(json['totalCount']).to eq 0
        end
      end
    end

    context 'could not find a @current_user' do
      it 'returns unauthorized', skip_auth: true do
        user = FactoryBot.create(:user, uid: '1u23', nickname: 'louise')

        allow_any_instance_of(Api::V1::AudiosController).to receive(:auth_token)
          .and_return({ 'blub' => 1412 })

        user.destroy

        get AUDIO_API_ENDPOINT, params: { working_on: true }

        expect(response.status).to eq(401)
      end
    end

    context 'by_user=true' do
      it 'returns audio uploaded by the authenticated user' do
        other_uploader = FactoryBot.create(:user)
        other_audio = FactoryBot.create(:audio, uploader: other_uploader)
        FactoryBot.create_list(:audio, 2, uploader: uploader)

        get AUDIO_API_ENDPOINT, params: { by_user: true }

        ids = json['audios'].map { |audio| audio[:id] }

        expect(json['totalCount']).to eq 2
        expect(ids).not_to include(other_audio.id)
      end

      it 'returns empty array if authenticated did not upload anything yet' do
        get AUDIO_API_ENDPOINT, params: { by_user: true }

        expect(json['totalCount']).to eq 0
        expect(json['audios']).to eq([])
      end
    end
  end

  describe 'SHOW' do
    let(:audio) { FactoryBot.create(:audio, uploader: uploader)}

    it 'returns an audio object if one is found' do
      get "#{AUDIO_API_ENDPOINT}#{audio.id}"

      expect(response.status).to eq 200
      expect(json['title']).to eq(audio.title)
      expect(json['id']).to eq(audio.id)
      expect(json['uploader']).to eq(uploader.nickname)
    end

    it 'returns a 404 if not found' do
      get "#{AUDIO_API_ENDPOINT}#{audio.id + 99}"

      expect(response.status).to eq 404
    end
  end

  describe 'SHOW with deleted uploader' do
    it 'returns something for uploader even if user has been perma-deleted' do
      louise = FactoryBot.create(:user, nickname: 'louise yang')
      audio = FactoryBot.create(:audio, uploader: louise)
      louise.destroy_fully!

      get "#{AUDIO_API_ENDPOINT}#{audio.id}"

      expect(response.status).to eq 200
      expect(json['uploader']).to_not be(nil)
    end
  end


  describe 'UPDATE' do
    let(:audio) { FactoryBot.create(:audio, uploader: uploader) }

    it 'updates appropriate field' do
      new_title = 'fee fie foe fum'

      put "#{AUDIO_API_ENDPOINT}#{audio.id}", params: { title: new_title }.to_json

      expect(json['title']).to eq(new_title)
    end

    it 'creates new contributors' do
      expect {
        put "#{AUDIO_API_ENDPOINT}#{audio.id}", params: { contributors: 'Mary Lantol, Badielin Mand' }.to_json
      }.to change{Contributor.count}.by(2)
    end

    it 'returns a 404 if audio not found' do
      put "#{AUDIO_API_ENDPOINT}#{audio.id + 99}", params: { title: 'new title here' }

      expect(response.status).to eq 404
    end
  end

  describe 'SEARCH' do
    before(:each) do
      FactoryBot.create(
          :audio,
          title: 'one two three',
          filename: 'filename1',
          tags: 'planes, trains, and automobiles',
          uploader: uploader
      )
      FactoryBot.create(
          :audio,
          title: 'training day',
          filename: 'filename2',
          tags: 'movies, denzel washington',
          uploader: uploader
      )
      FactoryBot.create(
          :audio,
          title: 'clueless',
          filename: 'no matchy',
          tags: 'movies, alicia',
          uploader: uploader
      )
    end

    it 'returns matching results' do
      get "#{AUDIO_API_ENDPOINT}search", params: { q: 'train' }

      expect(json['audios'].size).to eq(2)
    end

    it 'returns empty array when nothing matches' do
      get "#{AUDIO_API_ENDPOINT}search", params: { q: 'skelton key' }

      expect(json['audios'].size).to eq(0)
    end

    it "returns a result if there is a match on uploader name" do
      get "#{AUDIO_API_ENDPOINT}search", params: { q: uploader.nickname }

      expect(json['audios'].size).to eq(3)
    end
  end

  describe 'DESTROY' do
    let!(:audio) { FactoryBot.create(:audio, uploader: uploader) }

    it 'deletes audio file' do
      expect {
        delete "#{AUDIO_API_ENDPOINT}#{audio.id}"
      }.to change { Audio.count }.by(-1)

      expect(response.status).to eq 200
    end

    it 'does not delete an unfound file' do
      expect {
        delete "#{AUDIO_API_ENDPOINT}#{audio.id + 99}"
      }.to change { Audio.count }.by(0)

      expect(response.status).to eq 404
    end
  end
end
