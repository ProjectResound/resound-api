# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Audio, type: :model do
  it { is_expected.to belong_to(:uploader).class_name('User') }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_least(4) }
  it { is_expected.to validate_presence_of(:filename) }

  it do
    create(:audio)

    is_expected.to validate_uniqueness_of(:filename)
  end

  describe '#update_metadata' do
    let(:flac) { double(:flac, url: 'flac-url') }
    let(:he_aac) { double(:he_aac) }
    let(:mp3_128) { double(:mp3_128) }
    let(:file_hash) { { flac: flac, he_aac: he_aac, mp3_128: mp3_128 } }
    let(:audio) { create(:audio) }

    context 'when there is a flac file' do
      before do
        allow(audio).to receive(:file).and_return file_hash
        allow(File).to receive(:exist?).with(flac.url).and_return true
        allow(File).to receive(:open)
          .with("tmp/updates/#{audio.id}/#{audio.id}.flac", 'wb')
        allow(File).to receive(:open)
          .with("tmp/updates/#{audio.id}/#{audio.filename}.flac")
        allow(File).to receive(:open)
          .with("tmp/updates/#{audio.id}/#{audio.filename}.m4a")
        allow(File).to receive(:open)
          .with("tmp/updates/#{audio.id}/#{audio.filename}.mp3")
        allow(flac).to receive(:replace)
        allow(he_aac).to receive(:replace)
        allow(mp3_128).to receive(:replace)
      end

      it 'transcodes the file' do
        expect(audio).to receive(:transcode_updates)
          .with("tmp/updates/#{audio.id}/#{audio.id}.flac")

        audio.update_metadata
      end

      it 'saves the audio' do
        allow(audio).to receive(:transcode_updates)
          .with("tmp/updates/#{audio.id}/#{audio.id}.flac")

        expect(audio).to receive(:save)

        audio.update_metadata
      end
    end

    context "when there isn't a flac file" do
      before do
        allow(audio).to receive(:file).and_return file_hash
        allow(File).to receive(:exist?).with(flac.url).and_return false
      end

      it "doesn't transcode the file" do
        expect(audio).not_to receive(:transcode_updates)
          .with("tmp/updates/#{audio.id}/#{audio.id}.flac")

        audio.update_metadata
      end

      it 'saves the audio' do
        expect(audio).to receive(:save)

        audio.update_metadata
      end
    end
  end

  describe '.by_filename' do
    it 'returns audios that matches with the filename' do
      create(:audio)
      audio2 = create(:audio, filename: 'newFilename.mp3')

      expect(Audio.by_filename('newFilename.mp3')).to include audio2
    end
  end

  describe '.search' do
    it 'returns a result if there is a match' do
      audio = create(:audio, title: 'hello world')
      results = Audio.search('hello')

      expect(results).to exist
      expect(results.first.id).to be(audio.id)
    end

    it 'returns an empty array if there is no match' do
      expect(Audio.search('mojitos')).to be_empty
    end
  end
end
