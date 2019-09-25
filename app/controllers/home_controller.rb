# frozen_string_literal: true

# Home Controller
class HomeController < ApplicationController
  before_action :authenticate_user!, only: %i[signup dashboard]

  # GET /
  def index; end

  # POST /search
  def search; end

  # GET /dashboard
  def dashboard
    @data_management_plans = current_user.data_management_plans
  end

  # GET /login
  def login
    render template: '/users/login'
  end

  private

  def search_params
    params.require(:search).permit(:search_words)
  end
end
