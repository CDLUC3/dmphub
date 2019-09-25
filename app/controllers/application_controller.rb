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
end
