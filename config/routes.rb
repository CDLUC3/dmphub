# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

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

  get '/login', to: 'home#login', as: 'login'
  get '/dashboard', to: 'home#dashboard'
  get '/admin', to: 'admin#dashboard'
  get '/faq', to: 'home#faq'

  # Home page table controls
  post '/search', to: 'home#search'
  get '/page', to: 'home#page'
  get '/sort', to: 'home#sort'

  resources :projects, only: %w[new create edit update] do
    resources :awards
  end

  # Affiliation routes
  resources :affiliations, only: %w[update] do
    post 'merge'
  end
  get 'affiliations/search', to: 'affiliations#search'

  resources :data_management_plans, only: %i[show edit update]
  resources :datasets, only: %i[index]

  # Handles DOI resolution to a landing page
  get '/dmps/*id', to: 'data_management_plans#show', as: 'landing_page'

  get '/fundref_autocomplete', to: 'projects#fundref_autocomplete'

  # API versions
  namespace :api do
    namespace :v0 do
      post '/authenticate', format: :json, to: 'authentication#authenticate'
      get '/heartbeat', format: :json, to: 'base_api#heartbeat'

      get '/data_management_plans/*id', to: 'data_management_plans#show',
                                        as: 'data_management_plan',
                                        constraints: { id: /\S+/ }

      resources :data_management_plans, except: %w[show delete]
      resources :fundings, only: %w[index update]

      # get 'data_management_plans/*id', to: 'data_management_plans#show', as: 'data_management_plan', constraints: { id: /\S+/ }
      # put 'data_management_plans/*id', to: 'data_management_plans#update', constraints: { id: /\S+/ }
    end
  end
end
