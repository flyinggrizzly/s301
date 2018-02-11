Rails.application.routes.draw do
  resources :short_urls, path: 'short-urls'

  root 'short_urls#index'
end
