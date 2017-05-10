require 'spec_helper'
require 'transcoder'

describe Transcoder do
  before do
    @transcoder = Transcoder.new()
  end

  context 'when to_flac()' do
    module SuccessTrue
      def self.success?
        true
      end
    end
    module StubStatus
      def self.value
        SuccessTrue
      end
    end
    input_file = '/tmp/input.flac'
    output_file = '/tmp/output.flac'
    title = 'title'
    contributor = 'contributor'

    it 'raises an error when there is no binary path' do
      expect{@transcoder.to_flac(
          file: input_file,
          output_file: output_file,
          title: title,
          contributor: contributor)}.to raise_error StandardError
    end

    it 'raises an error when no title is supplied' do
      expect{@transcoder.to_flac(
          file: input_file,
          output_file: output_file,
          contributor: contributor)}.to raise_error ArgumentError
    end

    it 'returns a path to output file' do
      duration = '00:00:46.15'
      mock_process = double(:success? => true)
      allow(File).to receive(:exists?).and_return(true)
      response = ["", "ffmpeg version 3.1.3 Copyright (c) 2000-2016 the FFmpeg developers\n  built with Apple LLVM
version 7.3.0 (clang-703.0.31)\n  configuration: --prefix=/usr/local/Cellar/ffmpeg/3.1.3 --enable-shared --enable-pthreads
--enable-gpl --enable-version3 --enable-hardcoded-tables --enable-avresample --cc=clang --host-cflags= --host-ldflags=
--enable-opencl --enable-libx264 --enable-libmp3lame --enable-libxvid --enable-libfdk-aac --disable-lzma
--enable-nonfree --enable-vda\n  libavutil      55. 28.100 / 55. 28.100\n  libavcodec     57. 48.101 / 57. 48.101\n
libavformat    57. 41.100 / 57. 41.100\n  libavdevice    57.  0.101 / 57.  0.101\n  libavfilter
6. 47.100 /  6. 47.100\n  libavresample   3.  0.  0 /  3.  0.  0\n  libswscale      4.  1.100 /  4.  1.100\n
libswresample   2.  1.100 /  2.  1.100\n  libpostproc    54.  0.100 / 54.  0.100\nGuessed Channel Layout for Input
Stream #0.0 : mono\nInput #0, wav, from 'tmp/final/Audio_Recording_S693203_002.wav':\n  Duration: #{duration}, bitrate:
64 kb/s\n    Stream #0:0: Audio: pcm_mulaw ([7][0][0][0] / 0x0007), 8000 Hz, 1 channels, s16, 64 kb/s\nAt least one output
file must be specified\n", mock_process]
      allow(Open3).to receive(:capture3).and_return(response)

      expect(@transcoder.to_flac(file: input_file,
                                 output_file: output_file,
                                 title: title,
                                 contributor: contributor)).to eq(duration)
    end
  end
end