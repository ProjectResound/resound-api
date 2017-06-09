describe Api::V1::AudiosController do
  before(:each) do |example|
    unless example.metadata[:skip_auth]
      allow_any_instance_of(Api::V1::AudiosController).to receive(:authenticate_request!).and_return(true)
    end
  end

  describe 'CREATE' do
    context 'when a non-last chunk is received' do
      it 'does not combine all the chunks' do
        test_file = 'test.wav'
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'requests', test_file), 'audio/wav')
        allow(Dir).to receive(:[]).and_return(['chunk_file_directory/lalala1.wav.part1', 'chunk_file_directory/lalala2.wav.part2'])

        post '/api/v1/audios', params: { file: file,
             flowTotalChunks: 10,
             flowIdentifier: '123-lalala1' }

        expect(response.status).to eq 200
      end
    end

    context 'when a last chunk is received' do
      it 'enqueues a job' do
        ActiveJob::Base.queue_adapter = :test
        test_file = 'test.wav'
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'requests', test_file), 'audio/wav')
        allow(File).to receive(:size)
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:open).and_call_original
        allow(File).to receive(:open).with('tmp/final/lalala.wav.flac')

        expect {
        post '/api/v1/audios', params: { file: file,
                                         flowTotalChunks: 2,
                                         flowIdentifier: '123-lalala1',
                                         flowFilename: 'lalala.wav',
                                         title: 'lalad'}
        }.to have_enqueued_job(AudioProcessing)
      end
    end
  end

  describe 'GET' do
    context 'when unauthorized' do
      it 'returns 401', skip_auth: true do
        get '/api/v1/audios', params: { filename: 'something' }
        expect(response.status).to eq(401)
      end
    end
    context 'when it matches an object' do
      it 'returns an audio object' do
        title = 'title mcTitle'
        audio = Audio.create(
            title: title,
            filename: 'filename')

        get '/api/v1/audios', params: { filename: audio.filename }

        expect(response.status).to eq 200
        expect(json[0]['title']).to eq(title)
      end
    end
    context 'when there is no object' do
      audio = Audio.new()
      it 'returns nothing' do
        get '/api/v1/audios', params: { filename: audio.filename }

        expect(response.status).to eq 200
        expect(json).to be_empty
      end
    end
  end
end
