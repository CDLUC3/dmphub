# frozen_string_literal: true

module Users
  # User Sign up and Profile Controller
  class RegistrationsController < ApplicationController
    before_action :authenticate_user!, only: %i[edit update]

    # GET /users/edit
    def edit
      @user = current_user
    end

    # POST /users
    def create
      @user = User.new(user_params.merge(password: TokenService.generate_uuid))
      if @user.save
        # Create a Person record for the User that will be used if they create
        # any DMPs via our entry form
        person = Person.new(name: @user.name, email: @user.email)
        person.identifiers << Identifier.new(category: 'orcid',
          provenance: ConversionService.local_provenance, value: @user.orcid)
        person.save

        sign_in @user
        redirect_to dashboard_path, notice: 'Thank you for registering!'
      else
        flash[:alert] = @user.errors.map { |e, m| "#{e} - #{m}" }.join(', ')
      end
    end

    # PUT /users
    def update
      @user = current_user

      if @user.update(user_params)
        redirect_to dashboard_path, notice: 'Your chenages have been saved.'
      else
        flash[:alert] = @user.errors.map { |e, m| "#{e} - #{m}" }.join(', ')
      end
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email,
                                   :organization_id, :orcid)
    end
  end
end
