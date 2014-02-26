UserAccount::Application.routes.draw do
  resources :users

  root :to => 'movies#index'

  resources :movies do
    resources :reviews
    end
end
