# frozen_string_literal: true

# Home Controller
class HomeController < ApplicationController
  before_action :authenticate_user!, only: %i[signup dashboard]

  # GET /
  def index; end

  # POST /search
  def search; end

  # POST /filter
  def filter
    @page = 1
    @other_plans = paginate_response(results: apply_filters)&.order(:title)
  end

  # GET /dashboard
  def dashboard
    @data_management_plans = paginate_response(results: current_user.data_management_plans)&.order(:title)

    @funders = Organization.funders.order(:name)
    @organizations = Organization.all.order(:name) - @funders

    @other_plans = paginate_response(results: apply_filters)&.order(:title) if current_user.super_user?
  end

  # GET /login
  def login
    render template: '/users/login'
  end

  private

  def search_params
    params.require(:search).permit(:search_words)
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def apply_filters
    return all_dmps unless params[:organization_id].present? || params[:funder_id].present?

    if params[:organization_id].present? && !params[:funder_id].present?
      return DataManagementPlan.find_by_organization(
        organization_id: params[:organization_id]
      )
    end

    if params[:funder_id].present? && !params[:organization_id].present?
      return DataManagementPlan.find_by_funder(
        organization_id: params[:funder_id]
      )
    end

    DataManagementPlan.find_by_organization(organization_id: params[:organization_id])
                      .find_by_funder(organization_id: params[:funder_id])
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def all_dmps
    join_hash = {
      project: { awards: :identifiers },
      person_data_management_plans: :person
    }
    DataManagementPlan.includes(:identifiers, join_hash).all
  end
end
