# frozen_string_literal: true

# Base Application Controller
class ApplicationController < ActionController::Base
  private

  # Temporarily override the default root_path behavior to redirect users to the DMPTool
  # until we have decided what to do for the search/dashboard
  def root_path_location
    dmptool_url = 'https://dmptool.org/' if Rails.env.production?
    dmptool_url = 'https://dmptool-stg.cdlib.org/' unless dmptool_url.present?
    dmptool_url
  end

  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  def after_sign_up_path_for(_resource)
    dashboard_path
  end

  def after_sign_in_error_path_for(_resource)
    root_path_location
  end

  def after_sign_up_error_path_for(_resource)
    root_path_location
  end

  def pagination_params
    out = {
      page: params[:page] || 1,
      per_page: params[:per_page] || 25
    }
    out[:per_page] = 100 if out[:per_page] > 100

    # also set the instance variables for access in the views
    @page = out[:page]
    @per_page = out[:per_page]

    out
  end

  def sort_params
    out = {
      sort_col: params[:sort_col] || 'updated_at',
      sort_dir: params[:sort_dir] || 'desc'
    }

    # also set the instance variables for access in the views
    @sort_col = out[:sort_col]
    @sort_dir = out[:sort_dir]

    out
  end

  def paginate_response(results:)
    return results unless results.present?

    results.page(@page).per(@per_page)
  end
end
