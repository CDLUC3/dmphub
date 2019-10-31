# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
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
    # get '/users/sign_out', to: 'devise/sessions#destroy'
  end

  root to: 'home#index'

  get '/dashboard', to: 'home#dashboard'
  get '/admin', to: 'admin#dashboard'

  post '/search', to: 'home#search'
  post '/filter', to: 'home#filter'
  get '/login', to: 'home#login', as: 'login'

  resources :projects, only: %w[new create edit update] do
    resources :awards
  end
  resources :organizations, only: %w[update] do
    post 'merge'
  end

  resources :data_management_plans, only: %w[edit update]
  resources :datasets, only: %[index]

  # Handles DOI resolution to a landing page
  get '/dmps/*id', to: 'data_management_plans#show', as: 'landing_page'

  get '/fundref_autocomplete', to: 'projects#fundref_autocomplete'

  # API versions
  namespace :api do
    namespace :v0 do
      get '/me', format: :json, to: 'base_api#me'
      get '/heartbeat', format: :json, to: 'base_api#heartbeat'

      resources :data_management_plans, except: %w[show update]
      resources :awards, only: %w[index update]

      #get 'data_management_plans/*id', to: 'data_management_plans#show', as: 'data_management_plan', constraints: { id: /\S+/ }
      #put 'data_management_plans/*id', to: 'data_management_plans#update', constraints: { id: /\S+/ }
    end
  end
end
# rubocop:enable Metrics/BlockLength
