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

  post '/search', to: 'home#search'
  get '/login', to: 'home#login', as: 'login'

  # Handles DOI resolution to a landing page
  get 'data_management_plans/*id', to: 'data_management_plan#show', as: 'data_management_plan'

  resources :data_management_plan, only: %w[index edit update]

  # TODO: For some reason `resources` isn't working here. perhaps after we change model
  #       relationships from dmp -> projects to project -> dmps
  resources :projects, only: %w[new create edit update]

  resources :security_privacy_statements, only: %w[new create]

  #get '/projects/new', to: 'projects#new', as: 'new_project'
  #post '/projects', to: 'projects#create', as: 'projects', format: :json
  #get '/projects/:id', to: 'projects#edit', as: 'edit_project'
  #put '/projects/:id', to: 'projects#update', as: 'project', format: :json
  #resources :datasets, only: %[new create]
  #get '/datasets', to: 'datasets#index'
  #post '/datasets', to: 'datasets#create', format: :json
  #get '/datasets/new', to: 'datasets#new', as: 'new_dataset'
  #get '/datasets/edit/:id', to: 'datasets#edit', as: 'edit_dataset'
  #put '/datasets/:id', to: 'datasets#update', as: 'dataset', format: :json

  get '/fundref_autocomplete', to: 'projects#fundref_autocomplete'

  # API version 1
  namespace :api do
    namespace :v1 do
      get '/me', format: :json, to: 'base_api#me'
      get '/heartbeat', format: :json, to: 'base_api#heartbeat'

      get 'data_management_plans/*id', to: 'data_management_plans#show', as: 'data_management_plan', constraints: { id: /\S+/ }
      put 'data_management_plans/*id', to: 'data_management_plans#update', constraints: { id: /\S+/ }

      resources :data_management_plans, except: %w[show update]
      resources :datasets, only: %w[index show]
      resources :organizations, only: %w[index show]
      resources :persons, only: %w[index show]
      resources :projects, only: %w[index show]
      resources :users, only: %w[show]
    end
  end
end
# rubocop:enable Metrics/BlockLength
