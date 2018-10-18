# frozen_string_literal: true

require 'resque/server'

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :audios, only: %i[create index show update destroy] do
        collection do
          get 'search'
        end
      end
      resources :users, only: %i[create index get]
      resources :contributors, only: %i[create index]
    end
  end

  mount Resque::Server.new, at: '/resque'
  mount ActionCable.server => '/cable'

  # Return 200 for health check
  match '/', to: proc { [200, {}, ['']] }, via: :get

  # Return 404 for everything else
  match '*path', to: 'errors#not_found', via: :all
end
