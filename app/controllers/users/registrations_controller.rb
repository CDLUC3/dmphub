# frozen_string_literal: true

module Users
  # User Sign up and Profile Controller
  class RegistrationsController < ApplicationController
    include AffiliationSelectable

    before_action :authenticate_user!, only: %i[edit update]

    # GET /users/edit
    def edit
      @user = current_user
    end

    # POST /users
    def create
      attrs = user_params.merge(password: ApplicationService.generate_uuid)
      attrs = handle_affiliation(attrs: attrs)
      @user = User.new(attrs)
      if @user.save
        create_contributor_from_user(user: @user)
        sign_in @user
        redirect_to dashboard_path, notice: 'Thank you for registering!'
      else
        flash[:alert] = @user.errors.full_messages.join(', ')
      end
    end

    # PUT /users
    def update
      @user = current_user

      if @user.update(user_params)
        redirect_to dashboard_path, notice: 'Your chenages have been saved.'
      else
        flash[:alert] = @user.errors.full_messages.join(', ')
      end
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :orcid,
                                   affiliation: %i[id name])
    end

    # If this is a new user then create a corresponding contributor record for them
    def create_contributor_from_user(user:)
      return nil unless user.present?

      contributor = Contributor.find_or_create_by(orcid: user.orcid)
      return contributor unless contributor.new_record?

      provenance = Provenance.find_by(name: 'dmphub')
      contributor.update(
        name: [user.first_name, user.last_name].join(' '),
        email: user.email,
        affiliation_id: user.affiliation_id,
        provenance: provenance
      )
      Identifier.create(
        identifiable: contributor,
        category: 'orcid',
        descriptor: 'is_identified_by',
        provenance: provenance
      )
    end
  end
end
