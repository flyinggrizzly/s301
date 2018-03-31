Rails.application.routes.draw do
  resources :short_urls, path: 'short-urls' do
    get 'search', on: :collection
  end

  root 'short_urls#index'
end
