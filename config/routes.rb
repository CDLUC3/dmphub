# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper do
    # You can skip doorkeeper for non-api controllers here
    # skip_controllers :applications, :authorized_applications
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
    invitations: 'users/invitations'
  } do
    get '/users/sign_out', to: 'devise/sessions#destroy'
  end

  root to: 'home#index'

  # API version 1
  namespace :api do
    namespace :v1 do
      get '/me', format: :json, to: 'base_api#me'
      get '/heartbeat', format: :json, to: 'base_api#heartbeat'

      get 'data_management_plans/*id', to: 'data_management_plans#show', as: 'data_management_plan', constraints: { id: /\S+/ }
      resources :data_management_plans, except: %w[show]
      resources :datasets, only: %w[index show]
      resources :organizations, only: %w[index show]
      resources :persons, only: %w[index show]
      resources :projects, only: %w[index show]
      resources :users, only: %w[show]
    end
  end
end
