# frozen_string_literal: true

module Api
  module V1
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
        results = if params[:name]
                    Contributor.basic_search(params[:name])
                  else
                    Contributor.all
                  end
        render json: results
      end
    end
  end
end
