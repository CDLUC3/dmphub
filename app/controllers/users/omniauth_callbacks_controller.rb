# frozen_string_literal: true

module Users

  class OmniauthCallbacksController < ApplicationController

    def orcid
      @auth_hash = request.env["omniauth.auth"] || request.env
      token = @auth_hash[:credentials]['token']
      @user = User.from_omniauth_orcid(auth_hash: @auth_hash)

      email = OrcidService.email_lookup(orcid: @user.orcid, bearer_token: token).first unless @user.email.present?
      employment = OrcidService.employment_lookup(orcid: @user.orcid, bearer_token: token) unless @user.organization.present?
      @user.organization << Organization.find_or_initialize_by(employment) unless employment.blank?
      @user.save

      session[:user_id] = @user.id

      if @user.last_name.present? && @user.email.present? && @user.organizations.any?
        sign_in_and_redirect dashboard_path
      else
        sign_in_and_redirect edit_user_registration_path
        #render template: '/users/new'
      end
    end

    def failure
      redirect_to login_path
    end

  end

end
