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

    if current_user.super_user?
      # TODO: This is impractical, just here temporarily for testing with the NSF Awards
      #       data.
      query = <<-SQL
        SELECT dmp.id
        FROM data_management_plans dmp
          INNER JOIN projects proj ON dmp.id = proj.data_management_plan_id
          INNER JOIN awards a ON proj.id = a.project_id
          INNER JOIN identifiers i ON a.id = i.identifiable_id
            AND i.identifiable_type = 'Award' AND i.category = 5
      SQL

      results = ActiveRecord::Base.connection.execute(query)

      ids = results.collect.map { |result| result[0] }

      p ids

      @other_plans = DataManagementPlan.where(id: ids.to_a) if ids.any?
    end
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
