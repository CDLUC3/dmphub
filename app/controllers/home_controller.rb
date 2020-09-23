# frozen_string_literal: true

# Home Controller
class HomeController < ApplicationController
  before_action :authenticate_user!, only: %i[signup dashboard]

  before_action :pagination_params, only: %i[index search page sort dashboard]
  before_action :sort_params, only: %i[index search page sort dashboard]

  # GET /
  def index
    @data_management_plans = paginate_response(results: search_filter_and_sort)
  end

  # POST /search
  def search
    # Force back to page 1
    @page = 1
    @data_management_plans = paginate_response(results: search_filter_and_sort)
  end

  # GET /sort (triggered by remote links)
  def sort
    # Force back to page 1
    @page = 1
    @data_management_plans = paginate_response(results: search_filter_and_sort)
    render layout: false
  end

  # GET /page (triggered by remote links)
  def page
    @data_management_plans = paginate_response(results: search_filter_and_sort)
    render layout: false
  end

  # GET /faq
  def faq; end

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
    params.permit(:search_words)
  end

  def filter_params
    params.permit(:organization_id, :funder_id)
  end

  def search_filter_and_sort
    results = filter_params.present? ? apply_filters(results: results) : base_query.all
    results = apply_search(results: results) if search_params.present?
    results.order(order_clause)
  end

  def base_query
    DataManagementPlan.includes(:identifiers, project: { fundings: :affiliation })
                      .joins(:identifiers)
                      .left_outer_joins(project: { fundings: :affiliation })
                      .distinct
  end

  # Generate the ORDER BY clause
  def order_clause
    col = case sort_params[:sort_col]
          when 'title'
            'data_management_plans.title'
          when 'funder'
            'affiliations_fundings.name'
          else
            'data_management_plans.updated_at'
          end
    { "#{col}": :"#{sort_params[:sort_dir]}" }
  end

  # Apply any filtering criteria
  def apply_filters(results:)
    return results unless filter_params.present?

    if filter_params[:organization_id].present? && !filter_params[:funder_id].present?
      return DataManagementPlan.find_by_organization(
        organization_id: filter_params[:organization_id]
      )
    end

    if filter_params[:funder_id].present? && !filter_params[:organization_id].present?
      return DataManagementPlan.find_by_funder(
        organization_id: filter_params[:funder_id]
      )
    end

    DataManagementPlan.find_by_organization(organization_id: filter_params[:organization_id])
                      .find_by_funder(organization_id: filter_params[:funder_id])
  end

  # Apply any search criteria
  def apply_search(results:)
    return results unless search_params.present?

    terms = search_params[:search_words] || ''
    return results unless terms.present?

    results.search(term: terms)
  end

  def all_dmps
    join_hash = {
      project: { awards: %i[identifiers affiliation] },
      person_data_management_plans: :person
    }
    DataManagementPlan.includes(:identifiers, join_hash).all
  end
end
