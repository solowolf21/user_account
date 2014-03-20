UserAccount::Application.routes.draw do

  resources :genres

  root :to => 'movies#index'

  get '/movies/filter/:scope' => 'movies#index', :as => 'filtered_movies'
  resources :movies do
    resources :reviews
    resources :likes
  end

  resources :users
  get '/signup' => 'users#new', :as => 'signup'

  resource :session
end
