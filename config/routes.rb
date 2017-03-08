require 'resque/server'

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :audios, only: [:create, :index]
    end
  end

  mount Resque::Server.new, at: '/resque'
end
