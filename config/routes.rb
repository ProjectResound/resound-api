require 'resque/server'

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :audios, only: [:create, :index, :show, :update, :destroy] do
        collection do
          get 'search'
        end
      end
      resources :users, only: [:create, :index, :get]
      resources :contributors, only: [:create, :index]
    end
  end

  mount Resque::Server.new, at: '/resque'
  mount ActionCable.server => '/cable'

  # Return 200 for health check
  match '/', to: proc { [200, {}, ['']] }, via: :get

  # Return 404 for everything else
  match "*path", to: "errors#not_found", via: :all
end
