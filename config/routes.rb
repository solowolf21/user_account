UserAccount::Application.routes.draw do

  resources :genres

  root :to => 'movies#index'

  resources :movies do
    resources :reviews
    resources :likes
  end

  resources :users
  get '/signup' => 'users#new', :as => 'signup'

  resource :session
end
