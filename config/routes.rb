Rails.application.routes.draw do
  resources :passwords, controller: 'clearance/passwords', only: [:create, :new]
  resource  :session,   controller: 'clearance/sessions',  only: [:create]

  resources :users, only: [:new, :create, :index, :show, :delete, :destroy] do
    resource :password, controller: 'clearance/passwords', only: [:create, :edit, :update]
  end

  get    '/sign_in'   => 'clearance/sessions#new',     as: 'sign_in'
  delete '/sign_out'  => 'clearance/sessions#destroy', as: 'sign_out'

  resources :short_urls, path: 'short-urls'

  root 'short_urls#index'
end
