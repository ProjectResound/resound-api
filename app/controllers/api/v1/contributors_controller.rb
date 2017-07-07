module Api::V1
  class ContributorsController < BaseController
    include Secured

    def create
      if Contributor.basic_search(params[:name]).first
        render status: :no_content
        return
      end

      contributor = Contributor.create(name: params[:name])
      render json: contributor, status: :created
    end

    def index
      if (params[:name])
        results = Contributor.basic_search(params[:name])
      else
        results = Contributor.all
      end
      render json: results
    end

    private
  end
end