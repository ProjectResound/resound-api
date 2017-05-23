require 'resque/server'

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :audios, only: [:create, :index, :get] do
        collection do
          get 'search'
        end
      end
    end
  end

  mount Resque::Server.new, at: '/resque'

  mount ActionCable.server => '/cable'
end
