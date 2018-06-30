Rails.application.routes.draw do
  devise_for :users
  resources :short_urls, path: 'short-urls'

  root 'short_urls#index'
end
