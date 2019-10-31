# frozen_string_literal: true

# Administration Controller
class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :super_admin?


  # GET /admin
  def dashboard
    orgs = Organization.all&.order(:name)
    @full_list = orgs.map { |o| [o.name, o.id] }
    @organizations = paginate_response(results: orgs)&.order(:name)
  end


  private

  def admin_params

  end

  def super_admin?
    current_user.super_user?
  end

end
