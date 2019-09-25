# frozen_string_literal: true

module Users
  # ORCID Omniauth Controller
  class OmniauthCallbacksController < ApplicationController
    def orcid
      @auth_hash = request.env['omniauth.auth'] || request.env
      token = @auth_hash[:credentials]['token']
      @user = User.from_omniauth_orcid(auth_hash: @auth_hash)
      retry_extras(token: token)
      session[:user_id] = @user.id

      if @user.new_record?
        render new_user_registration_path
      else
        sign_in @user
        @user.update_user_orcid(auth_hash: @auth_hash)
        redirect_to dashboard_path
      end
    end

    def failure
      redirect_to login_path
    end

    private

    def retry_extras(token:)
      email = OrcidService.email_lookup(orcid: @user.orcid, bearer_token: token).first unless @user.email.present?
      @user.update(email: email) unless @user.email.present? || email.nil?
      employment = OrcidService.employment_lookup(orcid: @user.orcid, bearer_token: token) unless @user.organization.present?
      @user.organization << Organization.find_or_initialize_by(employment) unless employment.blank?
    end
  end
end
