# frozen_string_literal: true

module Users
  # ORCID Omniauth Controller
  class OmniauthCallbacksController < ApplicationController
    def orcid
      @auth_hash = request.env['omniauth.auth'] || request.env
      @user = User.from_omniauth_orcid(auth_hash: @auth_hash)

      if @user.new_record?
        @contributor = Contributor.find_by_orcid(@auth_hash[:uid])
        render new_user_registration_path unless @contributor.present?

        # If we found a matching contributor record for the ORCID then see if
        # we can find any additional info for the user
        @user.email = @contributor.email unless @user.email.present?
        @user.affiliation_id = @contributor.affiliation_id unless @user.affiliation_id.present?
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

    def retry_orcid_extras(token:)
      email = ExternalApis::OrcidService.email_lookup(orcid: @user.orcid, bearer_token: token).first
      @user.email = email unless email.nil?
      employment = ExternalApis::OrcidService.employment_lookup(orcid: @user.orcid, bearer_token: token).first
      @user.organizations << Organization.find_or_initialize_by(employment) unless employment.nil?
    end
  end
end
