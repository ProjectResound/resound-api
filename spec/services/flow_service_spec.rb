require 'spec_helper'

describe FlowService do
  subject(:flow_service) do
    FlowService.new(
      identifier: 'unique_id',
      filename: 'filename.wav',
      title: 'yaas audio',
      contributors: 'i made this'
    )
  end

  describe '#clean' do
    it 'removes chunk file directory' do
      expect(FileUtils).to receive(:rm_rf).with('tmp/flow/unique_id')

      flow_service.clean
    end

    it 'removes the final file' do
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.flac').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.128k.mp3').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.he-aac.m4a').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav').and_return true

      expect(FileUtils).to receive(:remove).with('tmp/final/filename.wav')

      flow_service.clean
    end

    it 'removes the final flac file' do
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.128k.mp3').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.he-aac.m4a').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.flac').and_return true

      expect(FileUtils).to receive(:remove).with('tmp/final/filename.wav.flac')

      flow_service.clean
    end

    it 'removes the final mp3 file' do
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.he-aac.m4a').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.flac').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.128k.mp3').and_return true

      expect(FileUtils).to receive(:remove).with('tmp/final/filename.wav.128k.mp3')

      flow_service.clean
    end

    it 'removes the final he-aac file' do
      allow(File).to receive(:exist?).with('tmp/final/filename.wav').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.flac').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.128k.mp3').and_return false
      allow(File).to receive(:exist?).with('tmp/final/filename.wav.he-aac.m4a').and_return true

      expect(FileUtils).to receive(:remove).with('tmp/final/filename.wav.he-aac.m4a')

      flow_service.clean
    end

    it 'returns true' do
      expect(subject.clean).to be_truthy
    end
  end

  describe '#combine_files' do
    before do
      3.times do |i|
        FileUtils.mkpath "tmp/flow/unique_id"
        File.open("tmp/flow/unique_id/filename.part#{i}", 'w+') do |f|
          f.write i.to_s*10 + "\n"
        end
      end
    end

    after do
      FileUtils.rm_rf "tmp/flow"
      FileUtils.rm_rf "tmp/final"
    end

    it "combine all '.part' files in one final file" do
      flow_service.combine_files

      expect(File.exist?("tmp/final/filename.wav")).to be_truthy
    end
  end

  describe '#transcode_file' do
    subject(:flow_service) do
      FlowService.new(
        identifier: 'mp3_id',
        filename: filename,
        title: 'skippityskip skip',
        contributors: 'louise yang'
      )
    end

    let(:transcoder) { double(:transcoder) }
    let(:duration) { double(:duration) }

    context 'when file is an mp3' do
      let(:filename) { 'filename.mp3' }

      it 'skips transcoding process' do
        allow(Transcoder).to receive(:new).and_return(transcoder)
        allow(transcoder).to receive(:get_duration).and_return(duration)

        expect(transcoder).not_to receive(:transcode)

        flow_service.transcode_file
      end

      it 'returns a hash containing only mp3 information' do
        allow(Transcoder).to receive(:new).and_return(transcoder)
        allow(transcoder).to receive(:get_duration).and_return(duration)

        result = flow_service.transcode_file

        expect(result).to eq({ duration: duration, mp3_file_path: "tmp/final/filename.mp3" })
      end
    end

    context 'when file is a wav' do
      let(:filename) { 'filename.wav' }

      it 'transcodes the file to FLAC' do
        allow(Transcoder).to receive(:new).and_return(transcoder)
        allow(transcoder).to receive(:get_duration).and_return(duration)
        allow(transcoder).to receive(:transcode).with(output: 'tmp/final/filename.wav.128k.mp3', format: Transcoder::MP3_128)
        allow(transcoder).to receive(:transcode).with(output: 'tmp/final/filename.wav.he-aac.m4a', format: Transcoder::HE_AAC)

        expect(transcoder).to receive(:transcode).with(output: 'tmp/final/filename.wav.flac', format: Transcoder::FLAC)


        flow_service.transcode_file
      end

      it 'transcodes the file to MP3' do
        allow(Transcoder).to receive(:new).and_return(transcoder)
        allow(transcoder).to receive(:get_duration).and_return(duration)
        allow(transcoder).to receive(:transcode).with(output: 'tmp/final/filename.wav.he-aac.m4a', format: Transcoder::HE_AAC)
        allow(transcoder).to receive(:transcode).with(output: 'tmp/final/filename.wav.flac', format: Transcoder::FLAC)

        expect(transcoder).to receive(:transcode).with(output: 'tmp/final/filename.wav.128k.mp3', format: Transcoder::MP3_128)


        flow_service.transcode_file
      end

      it 'transcodes the file to HE_ACC' do
        allow(Transcoder).to receive(:new).and_return(transcoder)
        allow(transcoder).to receive(:get_duration).and_return(duration)
        allow(transcoder).to receive(:transcode).with(output: 'tmp/final/filename.wav.128k.mp3', format: Transcoder::MP3_128)
        allow(transcoder).to receive(:transcode).with(output: 'tmp/final/filename.wav.flac', format: Transcoder::FLAC)

        expect(transcoder).to receive(:transcode).with(output: 'tmp/final/filename.wav.he-aac.m4a', format: Transcoder::HE_AAC)


        flow_service.transcode_file
      end

      it 'returns a hash containing information about mp3, he_aac and flac files' do
        allow(Transcoder).to receive(:new).and_return(transcoder)
        allow(transcoder).to receive(:get_duration).and_return(duration)
        allow(transcoder).to receive(:transcode).exactly(3).times

        result = flow_service.transcode_file

        expect(result).to eq(
          {
            duration: duration,
            mp3_file_path: "tmp/final/filename.wav.128k.mp3",
            final_flac_path: "tmp/final/filename.wav.flac",
            he_aac_file_path: "tmp/final/filename.wav.he-aac.m4a"
          }
        )
      end
    end
  end
end
