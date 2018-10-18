# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AudioSerializer do
  subject(:serializer) { AudioSerializer.new(audio) }

  describe '#uploader' do
    let(:audio) { create(:audio) }

    context "when uploader isn't deleted" do
      it 'returns the uploader nickname' do
        expect(serializer.uploader).to eq audio.uploader.nickname
      end
    end

    context 'when uploader is deleted' do
      it "returns 'deleted user'" do
        uploader = audio.uploader
        uploader.destroy

        expect(serializer.uploader).to eq 'deleted user'
      end
    end
  end

  describe '#files' do
    context "when file isn't present" do
      let(:audio) { Audio.new }

      it 'returns nil' do
        expect(serializer.files).to be nil
      end
    end

    context 'when file is present' do
      let(:mp3) { double(:mp3, url: 'mp3-url') }
      let(:flac) { double(:flac, url: 'flac-url') }
      let(:file_hash) { { mp3: mp3, flac: flac } }
      let(:audio) { Audio.new }

      it 'returns a hash containing the url related to the file format' do
        allow(audio).to receive(:file).and_return file_hash

        expect(serializer.files).to eq(mp3: 'mp3-url', flac: 'flac-url')
      end
    end
  end
end
