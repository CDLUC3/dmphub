# frozen_string_literal: true

# Project Controller
class ProjectsController < ApplicationController
  before_action :authenticate_user!

  # GET /projects/new
  def new
    @project = Project.new(
      awards: [Award.new],
      data_management_plan: DataManagementPlan.new(datasets: [Dataset.new])
    )
  end

  # POST /projects
  def create
    project = Project.from_json(
      provenance: ConversionService.local_provenance,
      json: params_to_rda_json
    )

    data_management_plan = DataManagementPlan.new(
      title: project.title,
      #language: 'en',
      datasets: [Dataset.new(title: 'Dataset')]
    )
    data_management_plan.projects << project

    @project = data_management_plan.projects.first

    if data_management_plan.save
      flash[:notice] = 'Your changes have been saved.'
      redirect_to edit_data_management_plan_path(data_management_plan)
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
    params.require(:project).permit(:title, :description, :start_on, :end_on,
                                    awards_attributes: [:funder_uri, :funder_name, :status,
                                                        identifiers_attributes: [:category,
                                                                                 :value]])
  end

  def params_to_rda_json
    ConversionService.project_form_params_to_rda(params: project_params)
  end

end
