# All API calls require authorization using an Authorization header from Auth0.
module Api::V1
  class AudiosController < BaseController
    include Secured

    before_action :find_audio, only: [:show, :update, :destroy]

    PER_PAGE = 25

    # Lists Audio objects.
    #
    # @param page [Integer] optional
    # @param filename [String] optional
    # @param working_on [Boolean] If true, returns the three recent Audios uploaded by the user.
    #
    # @return [Object] paginated object including an audios attribute that contains an array of audio.
    # @example
    #  GET /api/v1/audios =>
    #   {
    #     "audios": [
    #         {
    #             "id": 44,
    #             "title": "I got food in my belly",
    #             "uploader_id": "some_user_id",
    #             "filename": "Kurzweil-K2000-Dual-Bass-C1.wav",
    #             "duration": 7,
    #             "created_at": "2018-03-20T22:29:53.272Z",
    #             "updated_at": "2018-03-20T22:29:55.198Z",
    #             "tags": "sound effects, what should I do",
    #             "contributors": "louise"
    #         },
    #     ],
    #     "currentPage": 1,
    #         "totalPages": 1,
    #         "totalCount": 1,
    #         "perPage": 25
    #   }
    def index
      page = params[:page] || 1
      if params[:filename]
        audio = Audio.by_filename(params[:filename]).page(1).per(1)
      elsif params[:working_on] == 'true'
        audio = Audio.where(uploader_id: @current_user.id).page(1).order('created_at DESC').per(3)
      elsif params[:by_user]
        audio = Audio.where(uploader_id: @current_user.id).order('created_at DESC').page(page).per(PER_PAGE)
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

    # Returns the audio object
    #
    # @param id [Integer]
    # @return [Object] Audio object
    # @example
    #   GET /api/v1/audios/77 =>
    #   {
    #     "id": 77,
    #         "title": "booooong",
    #         "filename": "Kurzweil-K2000-Dual-Bass-C1.wav",
    #         "duration": 7,
    #         "created_at": "2018-03-20T22:29:53.272Z",
    #         "tags": "test",
    #         "contributors": "louise",
    #         "uploader": "louise.yang",
    #         "files": {
    #           "flac": "/uploads/store/something.flac",
    #           "he_aac": "/uploads/store/something.m4a",
    #           "mp3_128": "/uploads/store/something.mp3"
    #         }
    #   }
    def show
      if @audio
        render json: @audio
      else
        render status: :not_found
      end
    end

    # Creates an Audio object. From Resound-Store, this method can accept a flow.js (https://github.com/flowjs/flow.js)
    # type partial upload.
    #
    # @param title [String] audio file's title
    # @param contributors [String] comma-separated list of contributor names
    # @param tags [String] tags to identify this file by
    # @option flowFilename [String]
    # @option originalFilename [String]
    # @option flowIdentifier [String]
    def create
      save_file!
      if params[:flowFilename] && last_chunk?
        contributors = Contributor.parse_and_process(params[:contributors])
        filename = params[:originalFilename] || params[:flowFilename]
        audio = Audio.find_or_create_by(filename: filename)
        audio.title = params[:title]
        audio.contributors = contributors
        audio.tags = params[:tags]
        audio.uploader = @current_user
        audio.save!

        # Note(lyang): When replacing an existing file with a differently named file,
        # we need to update the :filename primary key.
        if params[:originalFilename] && (params[:originalFilename] != params[:flowFilename])
          audio.update_columns(filename: params[:flowFilename])
        end

        AudioProcessing.perform_later(
            { identifier: params[:flowIdentifier],
              filename: params[:flowFilename],
              title: params[:title],
              contributors: contributors }
        )
      else
        #   TBD: Upload by skipping flow.js, should we expect form data?
      end
      render status: :ok
    end

    # Updates the audio object. Requires a HTTP PUT request.
    # @param id [Integer] Audio ID, passed in as the resource ID in the endpoint.
    # @param body [JSON] json object
    # @example body JSON
    #   {
    #     "title": "September Frame Week Drive",
    #     "contributors": "Updated contributor name",
    #     "tags": "updated tags"
    #   }
    # @return Audio [JSON] Updated audio object, or 404 Not Found
    def update
      if @audio && request.body
        payload = JSON.parse(request.body.read)
        @audio.title = payload['title'] if payload['title']
        if payload['contributors']
          @audio.contributors = Contributor.parse_and_process(payload['contributors'])
        end
        @audio.tags = payload['tags'] if payload['tags']
        @audio.save!
        AudioUpdating.perform_later(@audio.id)
        render json: @audio
      else
        render status: :not_found
      end
    end

    # Search for Audio based on any arbitrary string.
    # @param q [String] query string
    # @return [JSON]
    # @example
    #   GET /api/v1/audios/search?q=test =>
    #   {
    #     "audios": [
    #         {
    #             "id": 42,
    #             "title": "I have the cymbal",
    #             "filename": "a-team_con_man2.wav",
    #             "tags": "test",
    #             "contributors": "louise",
    #             "duration": 13,
    #             "created_at": "2018-03-16T23:34:50.215Z",
    #             "uploader_nickname": "louise.yang",
    #             "rank35972011203815407": 0.0607927,
    #             "searchable_id": null
    #         },
    #         ...
    #     ],
    #     "currentPage": 1,
    #     "totalPages": 1,
    #     "totalCount": 3,
    #     "perPage": 100
    #   }
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

    # DANGER, Will Robinson! Destroys the audio object including all the different transcoded versions. This will make any
    # links to the different audio formats broken. Requires an HTTP DELETE request.
    #
    # @param id [Integer] Audio id
    # @return [HTTPStatus] :ok or :not_found
    # @example
    #   DELETE /api/v1/audios/41 =>
    #   200 OK
    def destroy
      if @audio
        @audio.destroy
        render status: :ok
      else
        render status: :not_found
      end
    end

    private

    def find_audio
      @audio = Audio.find_by_id(params[:id])
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