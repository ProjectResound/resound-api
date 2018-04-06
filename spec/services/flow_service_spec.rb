require 'spec_helper'
require 'transcoder'

describe FlowService do
  subject { FlowService.new(identifier: 'unique_id',
                            filename: 'filename.wav',
                            title: 'yaas audio',
                            contributors: 'i made this') }

  describe 'clean' do
    it 'is successful' do
      allow(FileUtils).to receive(:remove).and_return(true)
      expect(subject.clean).to be_truthy
    end
  end

  context 'when file is an mp3' do
    describe 'transcode' do
      it 'skips transcoding' do
        fake_file = double()
        fake_file.stub(:duration) { 123 }
        mp3_filename = 'somemp3.mp3'
        transcoder = double(Transcoder)
        allow(File).to receive(:exists?).with("tmp/final/somemp3").and_return(true)
        allow(FFMPEG::Movie).to receive(:new).and_return(fake_file)
        mp3_service = FlowService.new(
                                     identifier: 'mp3_id',
                                     filename: mp3_filename,
                                     title: 'skippityskip skip',
                                     contributors: 'louise yang'
        )
        transcoder.should_not_receive(:trancode_file)
        mp3_service.transcode_file
      end
    end
  end
end