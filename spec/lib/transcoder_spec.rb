# frozen_string_literal: true

require 'rails_helper'
require 'transcoder'

RSpec.describe Transcoder do
  let(:file) { double(:file) }
  let(:title) { double(:title) }
  let(:file_movie) { double(:file_movie, duration: 10) }
  let(:contributor) { double(:contributor) }

  describe '#transcode' do
    let(:output) { double(:output) }

    context 'transcoding to he-aac' do
      it 'transcodes the file with correct params' do
        allow(File).to receive(:exist?).with(file).and_return true
        allow(FFMPEG::Movie).to receive(:new).with(file).and_return(file_movie)
        allow(FFMPEG).to receive(:ffmpeg_binary=)

        transcoder = Transcoder.new(
          file: file,
          title: title,
          contributor: contributor
        )

        expect(file_movie).to receive(:transcode).with(
          output,
          audio_codec: 'libfdk_aac',
          audio_bitrate: '48',
          custom: ['-metadata',
                   "title=#{title}",
                   '-metadata',
                   "artist=#{contributor}"]
        )

        transcoder.transcode(output: output, format: Transcoder::HE_AAC)
      end

      it 'returns the file duration' do
        allow(File).to receive(:exist?).with(file).and_return true
        allow(FFMPEG::Movie).to receive(:new).with(file).and_return(file_movie)
        allow(FFMPEG).to receive(:ffmpeg_binary=)

        transcoder = Transcoder.new(
          file: file,
          title: title,
          contributor: contributor
        )

        allow(file_movie).to receive(:transcode)

        expect(transcoder.transcode(output: output, format: Transcoder::HE_AAC))
          .to eq file_movie.duration
      end
    end

    context 'transcoding to mp3' do
      it 'transcodes the file with correct params' do
        allow(File).to receive(:exist?).with(file).and_return true
        allow(FFMPEG::Movie).to receive(:new).with(file).and_return(file_movie)
        allow(FFMPEG).to receive(:ffmpeg_binary=)

        transcoder = Transcoder.new(
          file: file,
          title: title,
          contributor: contributor
        )

        expect(file_movie).to receive(:transcode).with(
          output,
          audio_codec: 'libmp3lame',
          audio_bitrate: '128',
          audio_bitdepth: '16',
          audio_channels: '2',
          custom: [
            '-metadata',
            "title=#{title}",
            '-metadata',
            "artist=#{contributor}"
          ]
        )

        transcoder.transcode(output: output, format: Transcoder::MP3_128)
      end

      it 'returns the file duration' do
        allow(File).to receive(:exist?).with(file).and_return true
        allow(FFMPEG::Movie).to receive(:new).with(file).and_return(file_movie)
        allow(FFMPEG).to receive(:ffmpeg_binary=)

        transcoder = Transcoder.new(
          file: file,
          title: title,
          contributor: contributor
        )

        allow(file_movie).to receive(:transcode)

        expect(
          transcoder.transcode(output: output, format: Transcoder::MP3_128)
        ).to eq file_movie.duration
      end
    end
  end

  describe '#duration' do
    it 'returns the file duration' do
      allow(File).to receive(:exist?).with(file).and_return true
      allow(FFMPEG::Movie).to receive(:new).with(file).and_return(file_movie)
      allow(FFMPEG).to receive(:ffmpeg_binary=)

      transcoder = Transcoder.new(
        file: file,
        title: title,
        contributor: contributor
      )

      expect(transcoder.duration).to eq file_movie.duration
    end
  end

  describe 'initialize' do
    context 'when passed file does not exist' do
      it 'raises a StandardError' do
        expect do
          Transcoder.new(
            file: 'wrong-path',
            title: title,
            contributor: contributor
          )
        end.to raise_error(StandardError, 'File does not exist: wrong-path')
      end
    end
  end
end
