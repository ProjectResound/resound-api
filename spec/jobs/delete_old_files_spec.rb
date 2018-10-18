# frozen_string_literal: true

require 'spec_helper'

describe DeleteOldFiles do
  include ActiveSupport::Testing::TimeHelpers

  describe '#perform' do
    let(:file_system) { double(:file_system) }

    before do
      travel 1.day
    end

    after do
      travel_back
    end

    it 'delete files older than 7 days' do
      allow(Shrine).to receive_message_chain(:storages, :[]) { file_system }

      expect(file_system).to receive(:clear!).with(older_than: 7.days.ago)

      DeleteOldFiles.perform_now
    end
  end
end
