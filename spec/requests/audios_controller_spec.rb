describe Api::V1::AudiosController do
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
      it 'combines all the chunks and returns a 201 status' do
        test_file = 'test.wav'
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'requests', test_file), 'audio/wav')
        allow(File).to receive(:size)
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:open).and_call_original
        allow(File).to receive(:open).with('tmp/final/lalala.wav.flac')

        post '/api/v1/audios', params: { file: file,
                      flowTotalChunks: 2,
                      flowIdentifier: '123-lalala1',
                      flowFilename: 'lalala.wav',
                      title: 'lalad'}

        expect(response.status).to eq 201
      end
    end
  end
end
