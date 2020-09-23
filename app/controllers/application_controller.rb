# frozen_string_literal: true

# Base Application Controller
class ApplicationController < ActionController::Base

  private

  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  def after_sign_up_path_for(_resource)
    dashboard_path
  end

  def after_sign_in_error_path_for(_resource)
    root_path
  end

  def after_sign_up_error_path_for(_resource)
    root_path
  end

  def pagination_params
    out = params.permit(:page, :per_page)
    out[:page] = 1 unless out[:page].present?
    out[:per_page] = 5 unless out[:per_page].present?
    out[:per_page] = 100 if out[:per_page] > 100

p "STRONG PARAMS: #{out[:page]}"

    # also set the instance variables for access in the views
    @page = out[:page]
    @per_page = out[:per_page]

    out
  end

  def sort_params
    out = params.permit(:sort_col, :sort_dir)
    out[:sort_col] = 'updated_at' unless out[:sort_col].present?
    out[:sort_dir] = 'desc' unless out[:sort_dir].present?

    # also set the instance variables for access in the views
    @sort_col = out[:sort_col]
    @sort_dir = out[:sort_dir]

    out
  end

  def paginate_response(results:)
    return results unless results.present?

p "PAGE: #{@page}, PER: #{@per_page}"

    results.page(@page).per(@per_page)
  end
end
