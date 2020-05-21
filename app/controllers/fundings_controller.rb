# frozen_string_literal: true

# Handles the Funding/Award sections
class FundingsController < ApplicationController
  # GET /fundings?project_id=:project_id
  def index
    @project = Project.find(params[:project_id])
  end

  # GET /fundings/new?project_id=:project_id
  def new
    project = Project.find(params[:project_id])
    @award = Funding.new(project: project)
  end
end
