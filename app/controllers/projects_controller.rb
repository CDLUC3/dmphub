# frozen_string_literal: true

# Project Controller
class ProjectsController < ApplicationController
  before_action :authenticate_user!

  # GET /projects/new
  def new
    @project = Project.new(
      awards: [Award.new],
      data_management_plans: [DataManagementPlan.new(datasets: [Dataset.new])]
    )
  end

  # POST /projects
  def create
    # Since a project is currently a child of a DMP in the RDA Common Standard model
    # we need to create a stub DMP and attach it's Project and initial Dataset
    data_management_plan = DataManagementPlan.new(
      title: project_params[:title],
      language: 'en',
      datasets: [Dataset.new(title: 'Dataset')],
      projects: [Project.new(project_params)]
    )

    if data_management_plan.save
      flash[:notice] = 'Your changes have been saved.'
      @project = data_management_plan.projects.first
      redirect_to awards_path(project_id: data_management_plan.projects.first.id)
    else
      flash[:alert] = 'Unable to save your changes!'
      render status: :unprocessable_entity
    end
  end

  # GET /fundref_autocomplete:q=:term
  def fundref_autocomplete
    json = FundrefService.find_by_name(name: params[:q])
    render json: json
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :start_on, :end_on)
  end

end
