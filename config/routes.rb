Rails.application.routes.draw do
  resources :short_urls
  
  root 'short_urls#index'
end
