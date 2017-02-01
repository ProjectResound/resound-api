require 'spec_helper'
require 'rails_helper'

RSpec.describe UploadController do
  describe 'POST #upload' do
    context 'when a non-last chunk is received' do
      it 'does not combine all the chunks' do
        test_file = 'test.wav'
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'controllers', test_file), 'audio/wav')
        allow(Dir).to receive(:[]).and_return(['chunk_file_directory/lalala1.wav.part1', 'chunk_file_directory/lalala2.wav.part2'])
        post :post, params: { file: file,
             flowTotalChunks: 10,
             flowIdentifier: '123-lalala1' }

        expect(response.status).to eq 200
      end
    end

    context 'when a last chunk is received' do
      it 'combines all the chunks and returns a 201 status' do
        test_file = 'test.wav'
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'controllers', test_file), 'audio/wav')
        allow(Dir).to receive(:[]).and_return(['chunk_file_directory/lalala1.wav.part1', 'chunk_file_directory/lalala2.wav.part2'])
        allow(File).to receive(:size)

        expect(@controller).to receive(:combine_file!) { true }
        expect(@controller).to receive(:transcode_file!) { true }

        post :post, params: { file: file,
                      flowTotalChunks: 2,
                      flowIdentifier: '123-lalala1',
                      flowFilename: 'lalala.wav' }

        expect(response.status).to eq 201
      end
      it 'initializes the transcoder' do
        test_file = 'test.wav'
        file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'controllers', test_file), 'audio/wav')
        allow(Dir).to receive(:[]).and_return(['chunk_file_directory/lalala1.wav.part1', 'chunk_file_directory/lalala2.wav.part2'])
        allow(File).to receive(:size)
        allow(File).to receive(:exists?).and_return(true)
        expect(@controller).to receive(:combine_file!) { true }
        expect_any_instance_of(Transcoder).to receive(:to_flac).and_return(true)

        post :post, params: { file: file,
                              flowTotalChunks: 2,
                              flowIdentifier: '123-lalala1',
                              flowFilename: 'lalala.wav' }
      end
    end
  end
end
