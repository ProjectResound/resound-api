module Api::V1
  class AudiosController < BaseController
    def index
    end

    def create
      save_file!
      if last_chunk?
        if audio = Audio.first_by_filename(params[:flowFilename])
          audio.title = params[:title]
          audio.save
        else
          audio = Audio.create(
                           title: params[:title],
                           filename: params[:flowFilename])
        end

        Resque.enqueue(AudioProcessing,
                       { identifier: params[:flowIdentifier],
                       filename: params[:flowFilename],
                       title: params[:title],
                       contributor: params[:contributor] })
      end

      render status: :ok
    end

    private

    def save_file!
      # Ensure required paths exist
      FileUtils.mkpath chunk_file_directory
      # Move the temporary file upload to the temporary chunk file path
      FileUtils.mv params['file'].tempfile, chunk_file_path(params[:flowFilename], params[:flowChunkNumber]), force: true
    end

    def last_chunk?
      for i in 1..params[:flowTotalChunks].to_i
        if !File.exists?(chunk_file_path(params[:flowFilename], i))
          return false
        end
      end
      return true
    end

    def chunk_file_path(fileName, number)
      File.join(chunk_file_directory, "#{fileName}.part#{number}")
    end

    def chunk_file_directory
      File.join "tmp", "flow", params[:flowIdentifier]
    end
  end
end