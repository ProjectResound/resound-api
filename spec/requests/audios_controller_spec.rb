describe Api::V1::AudiosController do
  AUDIO_API_ENDPOINT = '/api/v1/audios/'

  before(:each) do |example|
    @uploader = User.create(uid: '123', nickname: 'louise')

    allow(Net::HTTP).to receive(:start).and_return(double())
    unless example.metadata[:skip_auth]
      allow_any_instance_of(Api::V1::AudiosController).to receive(:auth_token).and_return(
          {'sub' => @uploader.uid, 'nickname' => @uploader.nickname}
      )
    end
  end

  describe 'CREATE' do
    context 'when a non-last chunk is received' do
      it 'does not combine all the chunks' do
        test_file = 'test.wav'
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'requests', test_file), 'audio/wav')
        allow(Dir).to receive(:[]).and_return(['chunk_file_directory/lalala1.wav.part1', 'chunk_file_directory/lalala2.wav.part2'])

        post AUDIO_API_ENDPOINT, params: {file: file,
                                          flowTotalChunks: 10,
                                          flowIdentifier: '123-lalala1' }

        expect(response.status).to eq 200
      end
    end

    context 'when a last chunk is received' do
      ActiveJob::Base.queue_adapter = :test
      test_file = 'test.wav'
      file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'requests', test_file), 'audio/wav')

      filename = 'lalala.wav'

      it 'enqueues a job and creates a new audio object' do
        allow(File).to receive(:size)
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:open).and_call_original
        allow(File).to receive(:open).with('tmp/final/lalala.wav.flac')

        expect {
        post AUDIO_API_ENDPOINT, params: {file: file,
                                          flowTotalChunks: 2,
                                          flowIdentifier: '123-lalala1',
                                          flowFilename: filename,
                                          title: 'lalad'}
        }.to have_enqueued_job(AudioProcessing)

        audio = Audio.by_filename(filename).first
        expect(audio.filename).to eq(filename)
      end
    end
  end

  describe 'GET' do
    context 'when unauthorized' do
      it 'returns 401', skip_auth: true do
        get AUDIO_API_ENDPOINT, params: {filename: 'something' }
        expect(response.status).to eq(401)
      end
    end
    context 'when it matches an object' do
      it 'returns an audio object' do
        title = 'title mcTitle'
        audio = Audio.create(
            title: title,
            filename: 'filename',
            uploader: @uploader)

        get AUDIO_API_ENDPOINT, params: {filename: audio.filename }

        expect(response.status).to eq 200
        expect(json[0]['title']).to eq(title)
      end
    end
    context 'when there is no object' do
      audio = Audio.new()
      it 'returns nothing' do
        get AUDIO_API_ENDPOINT, params: {filename: audio.filename }

        expect(response.status).to eq 200
        expect(json).to be_empty
      end
    end
  end

  describe 'SEARCH' do
    before(:each) do
      Audio.create(
          title: 'one two three',
          filename: 'filename1',
          tags: 'planes, trains, and automobiles',
          uploader: @uploader
      )
      Audio.create(
          title: 'training day',
          filename: 'filename2',
          tags: 'movies, denzel washington',
          uploader: @uploader
      )
      Audio.create(
          title: 'clueless',
          filename: 'no matchy',
          tags: 'movies, alicia',
          uploader: @uploader
      )
    end
    it 'returns matching results' do
      get "#{AUDIO_API_ENDPOINT}search", params: {q: 'train'}
      expect(json.size).to eq(2)
    end

    it 'returns empty array when nothing matches' do
      get "#{AUDIO_API_ENDPOINT}search", params: {q: 'skelton key'}
      expect(json.size).to eq(0)
    end

    it "returns a result if there is a match on uploader name" do
      get "#{AUDIO_API_ENDPOINT}search", params: {q: @uploader.nickname}
      expect(json.size).to eq(3)
    end

  end
end
