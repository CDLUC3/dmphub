# frozen_string_literal: true

# Administration Controller
class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :super_admin?

  # GET /admin
  def dashboard
    @data_management_plans = data_management_plan_lookup
  end

  # POST /search
  def search
    terms = search_params[:search_words] || ''
    dmps = data_management_plan_lookup
    dmps = dmps.search(term: terms) if terms.present?
    @data_management_plans = paginate_response(results: dmps)
  end

  private

  def admin_params; end

  def super_admin?
    current_user.super_user?
  end

  def data_management_plan_lookup
    ids = Contributor.includes(:contributors_data_mangement_plans)
                     .joins(:contributors_data_mangement_plans)
                     .where(email: current_user.email)
                     .pluck(contributors_data_mangement_plans: :data_management_plan_id)
    DataManagementPlan.where(id: ids)
  end
end
