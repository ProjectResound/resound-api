require 'spec_helper'

describe FlowService do
  subject { FlowService.new(identifier: 'unique_id',
                            filename: 'filename.wav',
                            title: 'yaas audio',
                            contributor: 'i made this') }

  describe 'clean' do
    it 'is successful' do
      allow(FileUtils).to receive(:remove).and_return(true)
      expect(subject.clean).to be_truthy
    end
  end
end