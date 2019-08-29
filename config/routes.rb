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

  root to: "home#index"
end
