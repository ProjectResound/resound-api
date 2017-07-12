module Api::V1
  class AudiosController < BaseController
    include Secured

    before_action :find_audio, only: [:show]

    PER_PAGE = Rails.env.production? ? 25 : 10

    def index
      page = params[:page] || 1
      if params[:filename]
        audio = Audio.by_filename(params[:filename]).page(1).per(1)
      elsif params[:working_on] == 'true'
        audio = Audio.where(uploader_id: @current_user.id).page(1).order('created_at DESC').per(3)
      else
        audio = Audio.order('created_at DESC').page(page).per(PER_PAGE)
      end
      render json: {
          audios: audio,
          currentPage: audio.current_page,
          totalPages: audio.total_pages,
          totalCount: audio.total_count,
          perPage: audio.limit_value
      }
    end

    def show
      render json: @audio
    end

    def create
      save_file!
      if last_chunk?
        contributors = Contributor.parse_and_process(params[:contributor])
        audio = Audio.find_or_create_by(filename: params[:flowFilename])
        audio.title = params[:title]
        audio.contributors = contributors
        audio.tags = params[:tags]
        audio.uploader = @current_user
        audio.save!

        AudioProcessing.perform_later(
            { identifier: params[:flowIdentifier],
              filename: params[:flowFilename],
              title: params[:title],
              contributor: contributors }
        )
      end
      render status: :ok
    end

    def search
      results = AudioSearchEngine.search(params[:q])
      render json: {
          audios: results,
          currentPage: 1,
          totalPages: 1,
          totalCount: results.size,
          perPage: 100
      }
    end

    private

    def find_audio
      @audio = Audio.find(params[:id])
    end

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