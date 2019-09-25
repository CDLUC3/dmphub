# frozen_string_literal: true

class HomeController < ApplicationController

  # GET /
  def index

  end

  # POST /search
  def search

  end

  private

  def search_params
    params.require(:search).permit(:search_words)
  end

end
