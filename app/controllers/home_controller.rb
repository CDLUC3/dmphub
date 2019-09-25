# frozen_string_literal: true

class HomeController < ApplicationController

  before_action :authenticate_user!, only: %i[signup dashboard]

  # GET /
  def index; end

  # POST /search
  def search

  end

  # GET /dashboard
  def dashboard; end

  # GET /login
  def login
    render template: '/users/login'
  end

  private

  def search_params
    params.require(:search).permit(:search_words)
  end

end
