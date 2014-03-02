UserAccount::Application.routes.draw do
  root :to => 'movies#index'

  resources :movies do
    resources :reviews
  end

  resources :users
  get '/signup' => 'users#new', :as => 'signup'

  resource :session
end
