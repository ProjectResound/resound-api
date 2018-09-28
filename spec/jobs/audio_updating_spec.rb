require 'spec_helper'

describe AudioUpdating do
  describe '#perform' do
    it 'updates the audio metadata' do
      audio = FactoryBot.create(:audio)

      expect_any_instance_of(Audio).to receive(:update_metadata)

      AudioUpdating.perform_now(audio.id)
    end
  end
end
