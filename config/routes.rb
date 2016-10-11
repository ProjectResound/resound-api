Rails.application.routes.draw do
  get 'upload', to: 'upload#index'

  post 'upload', to: 'upload#post'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
