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

  root to: 'errors#not_found'
end
