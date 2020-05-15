# frozen_string_literal: true

# Handles the Funding/Award sections
class AwardsController < ApplicationController
  # GET /awards?project_id=:project_id
  def index
    @project = Project.find(params[:project_id])
  end

  # GET /awards/new?project_id=:project_id
  def new
    project = Project.find(params[:project_id])
    @award = Award.new(project: project)
  end
end
