# frozen_string_literal: true

module Users
  # User Sign up and Profile Controller
  class RegistrationsController < ApplicationController
    before_action :authenticate_user!

    # GET /users/edit
    def edit
      @user = current_user
    end

    # PUT /users
    def update
      @user = current_user

      if @user.update(user_params)
        redirect_to dashboard_path, notice: 'Thank you for registering!'
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
