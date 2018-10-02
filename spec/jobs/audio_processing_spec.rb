require 'spec_helper'

describe AudioProcessing do
  describe '#perform' do
    let(:flow_service) { double(:flow_service ) }
    let(:server) { double(:server) }

    context "when there isn't an Audio with the passed filename" do
      let(:opts) do
        {
          identifier: 'unique_id',
          filename: 'filename.wav',
          title: 'Awesome Audio',
          contributors: 'Jhon Doe'
        }
      end

      it 'broadcast a failed message to FilesChannel' do
        allow(FlowService).to receive(:new).with(
          {
            identifier: opts[:identifier],
            filename: opts[:filename],
            title: opts[:title],
            contributors: opts[:contributors]
          }
        ).and_return(flow_service)
        allow(flow_service).to receive(:combine_files)
        allow(flow_service).to receive(:transcode_file)
        allow(ActionCable).to receive(:server).and_return(server)

        expect(server).to receive(:broadcast).with(
          'FilesChannel',
          {
            status: 'failed',
            trace: 'Could not find audio: filename.wav',
            filename: 'filename.wav'
          }
        )

        AudioProcessing.perform_now(opts)
      end
    end

    context "when there is an Audio with the passed filename" do
      let(:audio) { create(:audio) }
      let(:transcoded) do
        {
          final_flac_path: 'flac_path',
          he_aac_file_path: 'he_aac_path',
          mp3_file_path: 'mp3_path',
          duration: 30
        }
      end

      let(:opts) do
        {
          identifier: 'unique_id',
          filename: audio.filename,
          title: audio.title,
          contributors: 'Jhon Doe'
        }
      end

      it 'updates the audio with the new information' do
        allow(FlowService).to receive(:new).with(
          {
            identifier: opts[:identifier],
            filename: opts[:filename],
            title: opts[:title],
            contributors: opts[:contributors]
          }
        ).and_return(flow_service)
        allow(flow_service).to receive(:combine_files)
        allow(flow_service).to receive(:transcode_file).and_return(transcoded)
        allow(File).to receive(:open).with('flac_path').and_return('flac_content')
        allow(File).to receive(:open).with('he_aac_path').and_return('he_aac_content')
        allow(File).to receive(:open).with('mp3_path').and_return('mp3_content')
        allow(flow_service).to receive(:clean)
        allow(ActionCable).to receive(:server).and_return(server)
        allow(server).to receive(:broadcast)

        expect_any_instance_of(Audio).to receive(:duration=).with(30)
        expect_any_instance_of(Audio).to receive(:save)
        expect_any_instance_of(Audio).to receive(:update).with(
          file: { flac: 'flac_content', he_aac: 'he_aac_content', mp3_128: 'mp3_content'}
        )

        AudioProcessing.perform_now(opts)
      end

      it 'broadcast a success message to FilesChannel with file information' do
        allow(FlowService).to receive(:new).with(
          {
            identifier: opts[:identifier],
            filename: opts[:filename],
            title: opts[:title],
            contributors: opts[:contributors]
          }
        ).and_return(flow_service)
        allow(flow_service).to receive(:combine_files)
        allow(flow_service).to receive(:transcode_file).and_return(transcoded)
        allow(File).to receive(:open).exactly(3.times)
        allow(flow_service).to receive(:clean)
        allow_any_instance_of(Audio).to receive(:duration=)
        allow_any_instance_of(Audio).to receive(:save)
        allow_any_instance_of(Audio).to receive(:update)
        allow(ActionCable).to receive(:server).and_return(server)

        expect(server).to receive(:broadcast).with(
          'FilesChannel',
          {
            audio_id: audio.id,
            status: 'success',
            filename: audio.filename,
            contributors: opts[:contributors]
          }
        )

        AudioProcessing.perform_now(opts)
      end
    end

    context "when an exception raises" do
      let(:error) { StandardError.new('error') }
      let(:opts) do
        {
          identifier: 'unique_id',
          filename: 'filename.wav',
          title: 'Awesome Audio',
          contributors: 'Jhon Doe'
        }
      end

      it 'broadcast a failed message to FilesChannel with exception information' do
        allow(FlowService).to receive(:new).and_raise(error)
        allow(ActionCable).to receive(:server).and_return(server)

        expect(server).to receive(:broadcast).with(
          'FilesChannel',
          {
            status: 'failed',
            trace: error,
            filename: 'filename.wav'
          }
        )

        AudioProcessing.perform_now(opts)
      end
    end
  end
end
