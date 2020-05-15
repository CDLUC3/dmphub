# frozen_string_literal: true

# Base Application Controller
class ApplicationController < ActionController::Base
  before_action :pagination_params, only: %i[dashboard index]

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
    @page = params.fetch('page', 1).to_i
    @per_page = params.fetch('per_page', 15).to_i
  end

  def paginate_response(results:)
    return results unless results.present?

    results.page(@page).per(@per_page)
  end
end
