# frozen_string_literal: true

# Data Management Plan Controller
class DataManagementPlanController < ApplicationController
  before_action :authenticate_user!, except: %i[show]

  # GET /data_management_plan/:id
  def show
    p params[:id]

    doi = Identifier.where(value: params[:id], category: 'doi', identifiable_type: 'DataManagementPlan').first
    render status: 404 if doi.nil?

    @data_management_plan = DataManagementPlan.find(doi.identifiable_id)
  end

  # GET /data_management_plan/new
  def new; end

  # POST /data_management_plans
  def create; end
end
