Rails.application.routes.draw do
  use_doorkeeper
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root 'chats#index'
  resources :chats, only: [:index, :create]

  namespace :api do
    post 'chats/completion', to: 'chats#create', format: :json
  end
end
