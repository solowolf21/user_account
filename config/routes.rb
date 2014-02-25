UserAccount::Application.routes.draw do
  root :to => 'movies#index'

  resources :movies do
    resources :reviews
    end
end
