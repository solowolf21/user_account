UserAccount::Application.routes.draw do
  resources :users
  get '/signup' => 'users#new', :as => 'signup'

  root :to => 'movies#index'

  resources :movies do
    resources :reviews
    end
end
