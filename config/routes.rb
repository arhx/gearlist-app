Rails.application.routes.draw do
  root 'lists#index'

  resources :lists, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    get '/items/search', to: 'items#search', as: 'search_items'
    resources :items, only: [:new, :create, :edit, :update, :destroy]
  end


  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'logout'
end
